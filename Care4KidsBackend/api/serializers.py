import re
import uuid

from django.contrib.auth import authenticate
from django.utils import timezone
from rest_framework import serializers

from .models import ChildRegistrationCode, FamilyInvitation, Parent


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
    invitation_code = serializers.CharField(max_length=6, min_length=6)

    def validate_invitation_code(self, value):
        # Validate format - must be exactly 6 digits
        if not re.match(r"^\d{6}$", value):
            raise serializers.ValidationError(
                "Invitation code must be exactly 6 digits"
            )

        # Find the invitation by invitation_code
        try:
            invitation = FamilyInvitation.objects.get(
                invitation_code=value, status="pending"
            )
        except FamilyInvitation.DoesNotExist:
            raise serializers.ValidationError(
                "No pending invitation found for this code"
            )

        if invitation.is_expired:
            invitation.status = "expired"
            invitation.save()
            raise serializers.ValidationError("This invitation has expired")

        self.invitation = invitation
        return value


class AcceptInvitationSerializer(serializers.Serializer):
    invitation_code = serializers.CharField(max_length=6, min_length=6)
    full_name = serializers.CharField(max_length=100)
    password = serializers.CharField(write_only=True, min_length=8)
    password_confirm = serializers.CharField(write_only=True)

    def validate(self, attrs):
        if attrs["password"] != attrs["password_confirm"]:
            raise serializers.ValidationError("Passwords don't match")
        return attrs

    def validate_invitation_code(self, value):
        # Validate format - must be exactly 6 digits
        if not re.match(r"^\d{6}$", value):
            raise serializers.ValidationError(
                "Invitation code must be exactly 6 digits"
            )

        # Find the invitation by invitation_code
        try:
            invitation = FamilyInvitation.objects.get(
                invitation_code=value, status="pending"
            )
        except FamilyInvitation.DoesNotExist:
            raise serializers.ValidationError(
                "No pending invitation found for this code"
            )

        if invitation.is_expired:
            invitation.status = "expired"
            invitation.save()
            raise serializers.ValidationError("This invitation has expired")

        # Check if email already has an account
        if Parent.objects.filter(email=invitation.invited_email).exists():
            raise serializers.ValidationError("This email already has an account")

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


class ChatbotSerializer(serializers.Serializer):
    message = serializers.CharField(max_length=1000)
    conversation_id = serializers.CharField(max_length=100, required=False)

    def validate_message(self, value):
        if not value.strip():
            raise serializers.ValidationError("Message cannot be empty")
        return value.strip()


# Add this to your serializers.py


class GenerateChildCodeSerializer(serializers.Serializer):
    child_name = serializers.CharField(max_length=100)
    device_type = serializers.CharField(max_length=50, required=False, default="")
    device_model = serializers.CharField(max_length=100, required=False, default="")
    notes = serializers.CharField(max_length=500, required=False, default="")

    def validate_child_name(self, value):
        if not value.strip():
            raise serializers.ValidationError("Child name cannot be empty")
        return value.strip()

    def validate(self, attrs):
        request = self.context["request"]
        user = request.user
        child_name = attrs["child_name"]

        # Check if there's already a pending registration for this child name in this family
        existing_code = ChildRegistrationCode.objects.filter(
            child_name=child_name, family_id=user.family_id, status="pending"
        ).first()

        if existing_code and not existing_code.is_expired:
            raise serializers.ValidationError(
                f"A registration code is already pending for {child_name}"
            )

        return attrs

    def create(self, validated_data):
        request = self.context["request"]
        user = request.user

        # Cancel any existing pending codes for this child name in this family
        ChildRegistrationCode.objects.filter(
            child_name=validated_data["child_name"],
            family_id=user.family_id,
            status="pending",
        ).update(status="cancelled")

        # Prepare device info
        device_info = {
            "device_type": validated_data.get("device_type", ""),
            "device_model": validated_data.get("device_model", ""),
            "notes": validated_data.get("notes", ""),
            "expected_setup_date": timezone.now().isoformat(),
        }

        # Create new child registration code
        child_code = ChildRegistrationCode.objects.create(
            child_name=validated_data["child_name"],
            family_id=user.family_id,
            created_by=user,
            device_info=device_info,
        )

        return child_code


class AcceptChildCodeSerializer(serializers.Serializer):
    registration_code = serializers.CharField(max_length=6, min_length=6)
    device_id = serializers.CharField(max_length=100)  # Device unique identifier
    device_name = serializers.CharField(max_length=100, required=False, default="")
    device_os = serializers.CharField(max_length=50, required=False, default="")
    device_model = serializers.CharField(max_length=100, required=False, default="")
    app_version = serializers.CharField(max_length=20, required=False, default="")

    def validate_registration_code(self, value):
        # Validate format - must be exactly 6 digits
        if not re.match(r"^\d{6}$", value):
            raise serializers.ValidationError(
                "Registration code must be exactly 6 digits"
            )

        # Find the child registration code
        try:
            child_code = ChildRegistrationCode.objects.get(
                registration_code=value, status="pending"
            )
        except ChildRegistrationCode.DoesNotExist:
            raise serializers.ValidationError(
                "No pending registration found for this code"
            )

        if child_code.is_expired:
            child_code.status = "expired"
            child_code.save()
            raise serializers.ValidationError("This registration code has expired")

        # Store for use in create method
        self.child_code = child_code
        return value

    def validate_device_id(self, value):
        if not value.strip():
            raise serializers.ValidationError("Device ID is required")
        return value.strip()

    def create(self, validated_data):
        child_code = self.child_code

        # Prepare device monitoring info (convert datetime to ISO string)
        device_data = {
            "device_id": validated_data["device_id"],
            "device_name": validated_data.get(
                "device_name", f"{child_code.child_name}'s Device"
            ),
            "device_os": validated_data.get("device_os", ""),
            "device_model": validated_data.get("device_model", ""),
            "app_version": validated_data.get("app_version", ""),
            "linked_at": timezone.now().isoformat(),
            "status": "active",
        }

        # Update device info in registration code
        child_code.device_info.update(
            {
                "actual_device": device_data,
                "monitoring_enabled": True,
            }
        )

        # Mark as used
        child_code.status = "used"
        child_code.used_at = timezone.now()
        child_code.save()

        # Add child and device to MongoDB family
        self.add_child_to_mongodb_family(child_code, device_data)

        return child_code

    def add_child_to_mongodb_family(self, child_code, device_data):
        from utils.mongodb import mongodb_connection

        db = mongodb_connection.get_database()
        families_collection = db.families

        # Create child document with device for monitoring (convert datetime to ISO strings)
        child_data = {
            "child_id": str(uuid.uuid4()),
            "name": child_code.child_name,
            "registration_code": child_code.registration_code,
            "added_at": timezone.now().isoformat(),
            "added_by": child_code.created_by.id,
            "devices": [device_data],  # Array of monitored devices
            "monitoring_settings": {
                "screen_time_enabled": True,
                "app_restrictions_enabled": True,
                "location_tracking_enabled": False,  # Can be configured later
                "bedtime_mode_enabled": True,
            },
        }

        # Add child to family
        families_collection.update_one(
            {"family_id": child_code.family_id},
            {
                "$push": {"children": child_data},
                "$set": {"updated_at": timezone.now().isoformat()},
            },
        )
