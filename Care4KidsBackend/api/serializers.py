from django.contrib.auth import authenticate
from django.utils import timezone
from rest_framework import serializers

from .models import FamilyInvitation, Parent


class ParentRegistrationSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=8)
    password_confirm = serializers.CharField(write_only=True)

    class Meta:
        model = Parent
        fields = ["full_name", "email", "password", "password_confirm"]

    def validate(self, attrs):
        if attrs["password"] != attrs["password_confirm"]:
            raise serializers.ValidationError("Passwords don't match")
        return attrs

    def validate_email(self, value):
        if Parent.objects.filter(email=value).exists():
            raise serializers.ValidationError("Email already exists")
        return value

    def create(self, validated_data):
        # Remove password_confirm
        validated_data.pop("password_confirm")

        # Generate username from email (before @)
        email = validated_data["email"]
        base_username = email.split("@")[0]

        # Ensure username is unique
        username = base_username
        counter = 1
        while Parent.objects.filter(username=username).exists():
            username = f"{base_username}{counter}"
            counter += 1

        # Create Django user
        password = validated_data.pop("password")
        parent = Parent.objects.create_user(
            username=username,
            email=validated_data["email"],
            full_name=validated_data["full_name"],
        )
        parent.set_password(password)

        # Create family in MongoDB and link to Django user
        family_id = self.create_mongodb_family(parent)
        print(family_id)
        parent.family_id = family_id
        parent.save()

        return parent

    def create_mongodb_family(self, parent):
        import uuid

        from django.utils import timezone
        from utils.mongodb import mongodb_connection

        db = mongodb_connection.get_database()
        families_collection = db.families

        family_document = {
            "family_id": str(uuid.uuid4()),
            "family_name": None,  # Nullable - can be set later
            "created_at": timezone.now(),
            "django_user_id": parent.id,  # Link to Django user
            "parents": [
                {
                    "parent_id": str(parent.id),
                    "django_user_id": parent.id,
                    "full_name": parent.full_name,
                    "email": parent.email,
                    "phone": parent.phone,
                    "role": parent.role,
                    "username": parent.username,
                }
            ],
            "children": [],  # Empty initially - can add children later
            "family_settings": {
                "timezone": "America/New_York",
                "emergency_override_enabled": True,
                "default_bedtime": "21:00",
            },
        }

        result = families_collection.insert_one(family_document)
        return family_document["family_id"]


class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()  # Use email instead of username
    password = serializers.CharField(write_only=True)

    def validate(self, attrs):
        email = attrs.get("email")
        password = attrs.get("password")

        if email and password:
            # Find user by email
            try:
                parent = Parent.objects.get(email=email)
                user = authenticate(username=parent.username, password=password)

                if not user:
                    raise serializers.ValidationError("Invalid credentials")

                if not user.is_active:
                    raise serializers.ValidationError("Account is disabled")

                attrs["user"] = user
            except Parent.DoesNotExist:
                raise serializers.ValidationError("Invalid credentials")
        else:
            raise serializers.ValidationError("Email and password are required")

        return attrs


class SendFamilyInvitationSerializer(serializers.Serializer):
    email = serializers.EmailField()

    def validate_email(self, value):
        # Check if email already has an account
        if Parent.objects.filter(email=value).exists():
            raise serializers.ValidationError("This email already has an account")
        return value

    def validate(self, attrs):
        request = self.context["request"]
        user = request.user
        email = attrs["email"]

        # Check if there's already a pending invitation for this email to this family
        existing_invitation = FamilyInvitation.objects.filter(
            invited_email=email, family_id=user.family_id, status="pending"
        ).first()

        if existing_invitation and not existing_invitation.is_expired:
            raise serializers.ValidationError(
                "An invitation is already pending for this email"
            )

        return attrs

    def create(self, validated_data):
        request = self.context["request"]
        user = request.user

        # Cancel any existing pending invitations for this email to this family
        FamilyInvitation.objects.filter(
            invited_email=validated_data["email"],
            family_id=user.family_id,
            status="pending",
        ).update(status="cancelled")

        # Create new invitation
        invitation = FamilyInvitation.objects.create(
            invited_email=validated_data["email"],
            invited_by=user,
            family_id=user.family_id,
        )

        return invitation


class CheckInvitationSerializer(serializers.Serializer):
    email = serializers.EmailField()

    def validate_email(self, value):
        # Find the most recent pending invitation for this email
        invitation = (
            FamilyInvitation.objects.filter(invited_email=value, status="pending")
            .order_by("-created_at")
            .first()
        )

        if not invitation:
            raise serializers.ValidationError(
                "No pending invitation found for this email"
            )

        if invitation.is_expired:
            invitation.status = "expired"
            invitation.save()
            raise serializers.ValidationError(
                "The invitation for this email has expired"
            )

        self.invitation = invitation
        return value


class AcceptInvitationSerializer(serializers.Serializer):
    email = serializers.EmailField()
    full_name = serializers.CharField(max_length=100)
    password = serializers.CharField(write_only=True, min_length=8)
    password_confirm = serializers.CharField(write_only=True)

    def validate(self, attrs):
        if attrs["password"] != attrs["password_confirm"]:
            raise serializers.ValidationError("Passwords don't match")
        return attrs

    def validate_email(self, value):
        # Find the most recent pending invitation for this email
        invitation = (
            FamilyInvitation.objects.filter(invited_email=value, status="pending")
            .order_by("-created_at")
            .first()
        )

        if not invitation:
            raise serializers.ValidationError(
                "No pending invitation found for this email"
            )

        if invitation.is_expired:
            invitation.status = "expired"
            invitation.save()
            raise serializers.ValidationError(
                "The invitation for this email has expired"
            )

        # Store invitation for use in create method
        self.invitation = invitation
        return value

    def create(self, validated_data):
        invitation = self.invitation

        # Generate username from email
        email = invitation.invited_email
        base_username = email.split("@")[0]

        username = base_username
        counter = 1
        while Parent.objects.filter(username=username).exists():
            username = f"{base_username}{counter}"
            counter += 1

        # Create new parent
        parent = Parent.objects.create_user(
            username=username,
            email=invitation.invited_email,
            full_name=validated_data["full_name"],
            family_id=invitation.family_id,
            role="secondary",  # Second parent is secondary by default
        )
        parent.set_password(validated_data["password"])
        parent.save()

        # Add parent to MongoDB family document
        self.add_parent_to_mongodb_family(parent, invitation)

        # Mark invitation as accepted
        invitation.status = "accepted"
        invitation.accepted_at = timezone.now()
        invitation.save()

        return parent

    def add_parent_to_mongodb_family(self, parent, invitation):
        from utils.mongodb import mongodb_connection

        db = mongodb_connection.get_database()
        families_collection = db.families

        # Add parent to the existing family document
        new_parent_data = {
            "parent_id": str(parent.id),
            "django_user_id": parent.id,
            "full_name": parent.full_name,
            "email": parent.email,
            "phone": parent.phone,
            "role": parent.role,
            "username": parent.username,
            "joined_at": timezone.now(),
        }

        families_collection.update_one(
            {"family_id": invitation.family_id},
            {
                "$push": {"parents": new_parent_data},
                "$set": {"updated_at": timezone.now()},
            },
        )
