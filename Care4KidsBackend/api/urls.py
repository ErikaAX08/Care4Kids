from django.urls import path

from .views import LoginView  # Your existing views
from .views import (AcceptChildCodeView,  # Add AcceptChildCodeView
                    AcceptInvitationView, ChatbotView, CheckInvitationView,
                    FirstNameView, GenerateChildCodeView, LogoutView,
                    MyChildCodesView, MyInvitationsView,
                    ParentRegistrationView, SendFamilyInvitationView,
                    UserProfileView)

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
    # Child registration endpoints
    path(
        "children/generate-code/",
        GenerateChildCodeView.as_view(),
        name="generate-child-code",
    ),
    path(
        "children/accept-code/", AcceptChildCodeView.as_view(), name="accept-child-code"
    ),
    path("children/my-codes/", MyChildCodesView.as_view(), name="my-child-codes"),
]
