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

    invitation_id = models.UUIDField(default=uuid.uuid4, editable=False, unique=True)
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
        if not self.expires_at:
            self.expires_at = timezone.now() + timedelta(days=7)  # 7 days to accept
        super().save(*args, **kwargs)

    @property
    def is_expired(self):
        return timezone.now() > self.expires_at and self.status == "pending"

    def __str__(self):
        return f"Invitation to {self.invited_email} for family {self.family_id}"
