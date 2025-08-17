from django.contrib import admin
from django.contrib.auth.admin import UserAdmin

from .models import Parent


@admin.register(Parent)
class ParentAdmin(UserAdmin):
    """Admin interface for Parent model"""

    # Customize fieldsets for simplified model
    fieldsets = (
        (None, {"fields": ("username", "password")}),
        ("Personal info", {"fields": ("full_name", "email", "phone")}),
        ("Family info", {"fields": ("family_id", "role", "is_verified")}),
        (
            "Permissions",
            {
                "fields": (
                    "is_active",
                    "is_staff",
                    "is_superuser",
                    "groups",
                    "user_permissions",
                ),
            },
        ),
        ("Important dates", {"fields": ("last_login", "date_joined")}),
    )

    add_fieldsets = (
        (
            None,
            {
                "classes": ("wide",),
                "fields": ("username", "full_name", "email", "password1", "password2"),
            },
        ),
    )

    list_display = [
        "username",
        "email",
        "full_name",
        "role",
        "family_id",
        "is_verified",
        "is_active",
    ]
    list_filter = ["role", "is_verified", "is_active", "date_joined"]
    search_fields = ["username", "email", "full_name", "family_id"]
    ordering = ["email"]
