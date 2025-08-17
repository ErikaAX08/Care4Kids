from django.urls import path

from .views import LoginView  # Your existing views
from .views import (AcceptInvitationView, ChatbotView,  # Add FirstNameView
                    CheckInvitationView, FirstNameView, LogoutView,
                    MyInvitationsView, ParentRegistrationView,
                    SendFamilyInvitationView, UserProfileView)

urlpatterns = [
    # Authentication endpoints
    path("auth/register/", ParentRegistrationView.as_view(), name="parent-register"),
    path("auth/login/", LoginView.as_view(), name="parent-login"),
    path("auth/logout/", LogoutView.as_view(), name="parent-logout"),
    path("auth/profile/", UserProfileView.as_view(), name="user-profile"),
    # Family invitation endpoints
    path(
        "invitations/send/", SendFamilyInvitationView.as_view(), name="send-invitation"
    ),
    path("invitations/check/", CheckInvitationView.as_view(), name="check-invitation"),
    path(
        "invitations/accept/", AcceptInvitationView.as_view(), name="accept-invitation"
    ),
    path("invitations/my/", MyInvitationsView.as_view(), name="my-invitations"),
    # Chatbot endpoint
    path("chatbot/", ChatbotView.as_view(), name="chatbot"),
    # User utilities
    path("auth/first-name/", FirstNameView.as_view(), name="first-name"),
]
