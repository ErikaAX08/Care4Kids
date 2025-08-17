import random
import uuid
from datetime import timedelta

from django.contrib.auth.models import AbstractUser
from django.db import models
from django.utils import timezone


class Parent(AbstractUser):
    """Extended User model for parents"""

    full_name = models.CharField(max_length=100)
    phone = models.CharField(max_length=20, blank=True)
    family_id = models.CharField(max_length=100, blank=True)
    role = models.CharField(
        max_length=20,
        choices=[("primary", "Primary"), ("secondary", "Secondary")],
        default="primary",
    )
    is_verified = models.BooleanField(default=False)

    first_name = None
    last_name = None

    class Meta:
        db_table = "parents"


class FamilyInvitation(models.Model):
    """Model to handle family invitations"""

    invitation_code = models.CharField(max_length=6, unique=True, editable=False)
    invited_email = models.EmailField()
    invited_by = models.ForeignKey(
        Parent, on_delete=models.CASCADE, related_name="sent_invitations"
    )
    family_id = models.CharField(max_length=100)
    status = models.CharField(
        max_length=20,
        choices=[
            ("pending", "Pending"),
            ("accepted", "Accepted"),
            ("expired", "Expired"),
            ("cancelled", "Cancelled"),
        ],
        default="pending",
    )
    created_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField()
    accepted_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = "family_invitations"
        unique_together = ["invited_email", "family_id", "status"]

    def save(self, *args, **kwargs):
        if not self.invitation_code:
            self.invitation_code = self.generate_unique_code()
        if not self.expires_at:
            self.expires_at = timezone.now() + timedelta(days=7)  # 7 days to accept
        super().save(*args, **kwargs)

    @staticmethod
    def generate_unique_code():
        """Generate a unique 6-digit invitation code"""
        max_attempts = 100
        for _ in range(max_attempts):
            code = str(random.randint(100000, 999999))
            if not FamilyInvitation.objects.filter(invitation_code=code).exists():
                return code
        # If we can't find a unique code after max_attempts, raise an error
        raise ValueError("Unable to generate unique invitation code")

    @property
    def is_expired(self):
        return timezone.now() > self.expires_at and self.status == "pending"

    def __str__(self):
        return f"Invitation {self.invitation_code} to {self.invited_email} for family {self.family_id}"


# Add this to your models.py


class ChildRegistrationCode(models.Model):
    """Model to handle child registration codes"""

    registration_code = models.CharField(max_length=6, unique=True, editable=False)
    child_name = models.CharField(max_length=100)
    family_id = models.CharField(max_length=100)
    created_by = models.ForeignKey(
        Parent, on_delete=models.CASCADE, related_name="child_registrations"
    )
    status = models.CharField(
        max_length=20,
        choices=[
            ("pending", "Pending"),
            ("used", "Used"),
            ("expired", "Expired"),
            ("cancelled", "Cancelled"),
        ],
        default="pending",
    )
    created_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField()
    used_at = models.DateTimeField(null=True, blank=True)

    # Device information (stored as JSON for flexibility)
    device_info = models.JSONField(default=dict, blank=True)

    class Meta:
        db_table = "child_registration_codes"

    def save(self, *args, **kwargs):
        if not self.registration_code:
            self.registration_code = self.generate_unique_code()
        if not self.expires_at:
            self.expires_at = timezone.now() + timedelta(hours=24)  # 24 hours to use
        super().save(*args, **kwargs)

    @staticmethod
    def generate_unique_code():
        """Generate a unique 6-digit child registration code"""
        max_attempts = 100
        for _ in range(max_attempts):
            code = str(random.randint(100000, 999999))
            if not ChildRegistrationCode.objects.filter(
                registration_code=code
            ).exists():
                return code
        raise ValueError("Unable to generate unique child registration code")

    @property
    def is_expired(self):
        return timezone.now() > self.expires_at and self.status == "pending"

    def __str__(self):
        return f"Child registration {self.registration_code} for {self.child_name} in family {self.family_id}"
