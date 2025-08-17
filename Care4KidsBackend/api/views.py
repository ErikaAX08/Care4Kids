import logging

import google.generativeai as genai
from django.conf import settings
from django.contrib.auth import login, logout
from django.utils import timezone
from django.utils.decorators import method_decorator
from django.views.decorators.csrf import csrf_exempt
from rest_framework import status
from rest_framework.authtoken.models import Token
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import FamilyInvitation, Parent
from .serializers import (AcceptInvitationSerializer, ChatbotSerializer,
                          CheckInvitationSerializer, LoginSerializer,
                          ParentRegistrationSerializer,
                          SendFamilyInvitationSerializer)

logger = logging.getLogger(__name__)


@method_decorator(csrf_exempt, name="dispatch")
class ParentRegistrationView(APIView):
    """Register parent with simplified fields: full_name, email, password"""

    permission_classes = [AllowAny]

    def post(self, request):
        serializer = ParentRegistrationSerializer(data=request.data)
        print(request.data)
        print(serializer.is_valid())
        if not serializer.is_valid():
            return Response(
                {"success": False, "errors": serializer.errors},
                status=status.HTTP_400_BAD_REQUEST,
            )
        print(serializer.is_valid())
        try:
            parent = serializer.save()
            # Create auth token
            token, created = Token.objects.get_or_create(user=parent)
            logger.info(f"New parent registered: {parent.username} ({parent.email})")
            return Response(
                {
                    "success": True,
                    "message": "Registration successful",
                    "user": {
                        "id": parent.id,
                        "username": parent.username,  # Generated from email
                        "email": parent.email,
                        "full_name": parent.full_name,
                        "family_id": parent.family_id,
                        "role": parent.role,
                        "is_verified": parent.is_verified,
                    },
                    "token": token.key,
                    "next_steps": [
                        "Family created successfully",
                        "You can now add children to your family",
                        "Set up devices for parental control",
                    ],
                },
                status=status.HTTP_201_CREATED,
            )
        except Exception as e:
            logger.error(f"Registration failed: {str(e)}")
            return Response(
                {"success": False, "error": f"Registration failed: {str(e)}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )


@method_decorator(csrf_exempt, name="dispatch")
class LoginView(APIView):
    """Login with email and password"""

    permission_classes = [AllowAny]

    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(
                {"success": False, "errors": serializer.errors},
                status=status.HTTP_400_BAD_REQUEST,
            )

        user = serializer.validated_data["user"]
        # Create Django session
        login(request, user)
        # Get or create token
        token, created = Token.objects.get_or_create(user=user)
        logger.info(f"User logged in: {user.username} ({user.email})")

        return Response(
            {
                "success": True,
                "message": "Login successful",
                "user": {
                    "id": user.id,
                    "username": user.username,
                    "email": user.email,
                    "full_name": user.full_name,
                    "family_id": user.family_id,
                    "role": user.role,
                    "is_verified": user.is_verified,
                },
                "token": token.key,
            }
        )


@method_decorator(csrf_exempt, name="dispatch")
class LogoutView(APIView):
    """Logout user and delete token"""

    def post(self, request):
        try:
            # Delete the user's token
            if hasattr(request.user, "auth_token"):
                request.user.auth_token.delete()
            # Django logout
            logout(request)
            return Response({"success": True, "message": "Logged out successfully"})
        except Exception as e:
            return Response(
                {"success": False, "error": str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )


class UserProfileView(APIView):
    """Get current user profile"""

    def get(self, request):
        user = request.user
        return Response(
            {
                "success": True,
                "user": {
                    "id": user.id,
                    "username": user.username,
                    "email": user.email,
                    "full_name": user.full_name,
                    "family_id": user.family_id,
                    "role": user.role,
                    "is_verified": user.is_verified,
                    "date_joined": user.date_joined,
                    "last_login": user.last_login,
                },
            }
        )


class SendFamilyInvitationView(APIView):
    """Send invitation to join family (requires authentication)"""

    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = SendFamilyInvitationSerializer(
            data=request.data, context={"request": request}
        )
        if not serializer.is_valid():
            return Response(
                {"success": False, "errors": serializer.errors},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            invitation = serializer.save()
            logger.info(
                f"Family invitation sent by {request.user.username} to {invitation.invited_email}"
            )
            return Response(
                {
                    "success": True,
                    "message": "Family invitation created successfully",
                    "invitation": {
                        "invitation_code": invitation.invitation_code,
                        "invited_email": invitation.invited_email,
                        "family_id": invitation.family_id,
                        "expires_at": invitation.expires_at,
                        "status": invitation.status,
                    },
                    "instructions": [
                        f"Share this 6-digit invitation code with {invitation.invited_email}:",
                        f"Code: {invitation.invitation_code}",
                        "They can use this code to check and accept the invitation",
                    ],
                },
                status=status.HTTP_201_CREATED,
            )
        except Exception as e:
            logger.error(f"Failed to send invitation: {str(e)}")
            return Response(
                {"success": False, "error": f"Failed to send invitation: {str(e)}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )


@method_decorator(csrf_exempt, name="dispatch")
class CheckInvitationView(APIView):
    """Check if invitation is valid using 6-digit invitation code (public endpoint)"""

    permission_classes = [AllowAny]

    def post(self, request):
        serializer = CheckInvitationSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(
                {"success": False, "errors": serializer.errors},
                status=status.HTTP_400_BAD_REQUEST,
            )

        invitation = serializer.invitation
        return Response(
            {
                "success": True,
                "message": "Invitation found and is valid",
                "invitation": {
                    "invitation_code": invitation.invitation_code
                    or str(invitation.invitation_id),
                    "invited_email": invitation.invited_email,
                    "invited_by": invitation.invited_by.full_name,
                    "family_id": invitation.family_id,
                    "expires_at": invitation.expires_at,
                    "status": invitation.status,
                    "days_remaining": (invitation.expires_at - timezone.now()).days,
                },
                "next_step": "Use /api/invitations/accept/ with this invitation code to accept the invitation",
            }
        )


@method_decorator(csrf_exempt, name="dispatch")
class AcceptInvitationView(APIView):
    """Accept family invitation using 6-digit invitation code and create account"""

    permission_classes = [AllowAny]

    def post(self, request):
        serializer = AcceptInvitationSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(
                {"success": False, "errors": serializer.errors},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            parent = serializer.save()
            # Create auth token
            token, created = Token.objects.get_or_create(user=parent)
            # Auto-login the new user
            login(request, parent)
            logger.info(f"Family invitation accepted by {parent.email}")

            return Response(
                {
                    "success": True,
                    "message": "Invitation accepted successfully! Welcome to the family!",
                    "user": {
                        "id": parent.id,
                        "username": parent.username,
                        "email": parent.email,
                        "full_name": parent.full_name,
                        "family_id": parent.family_id,
                        "role": parent.role,
                        "is_verified": parent.is_verified,
                    },
                    "token": token.key,
                },
                status=status.HTTP_201_CREATED,
            )
        except Exception as e:
            logger.error(f"Failed to accept invitation: {str(e)}")
            return Response(
                {"success": False, "error": f"Failed to accept invitation: {str(e)}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )


class MyInvitationsView(APIView):
    """Get invitations sent by current user"""

    permission_classes = [IsAuthenticated]

    def get(self, request):
        invitations = FamilyInvitation.objects.filter(invited_by=request.user).order_by(
            "-created_at"
        )
        invitation_list = []
        for inv in invitations:
            invitation_list.append(
                {
                    "invitation_code": inv.invitation_code or str(inv.invitation_id),
                    "invited_email": inv.invited_email,
                    "status": inv.status,
                    "created_at": inv.created_at,
                    "expires_at": inv.expires_at,
                    "accepted_at": inv.accepted_at,
                    "is_expired": inv.is_expired,
                }
            )

        return Response(
            {
                "success": True,
                "invitations": invitation_list,
                "total_sent": len(invitation_list),
            }
        )


@method_decorator(csrf_exempt, name="dispatch")
class ChatbotView(APIView):
    """Simple chatbot using Gemini API"""

    permission_classes = [IsAuthenticated]

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        # Configure Gemini API
        genai.configure(api_key=settings.GEMINI_API_KEY)
        self.model = genai.GenerativeModel("gemini-1.5-flash")

    def post(self, request):
        serializer = ChatbotSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(
                {"success": False, "errors": serializer.errors},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            user_message = serializer.validated_data["message"]

            # Add context about the user and family app
            system_context = f"""
            Eres un chatbot asistente familiar muy útil. El nombre del usuario es {request.user.full_name} 
            y forma parte de un sistema de gestión familiar. Puedes ayudar con preguntas generales 
            sobre crianza de hijos, organización familiar, y brindar conversación amigable.
            Mantén tus respuestas útiles, apropiadas para toda la familia, y concisas.
            Responde siempre en español.
            """

            # Combine context with user message
            full_prompt = f"{system_context}\n\nUser: {user_message}"

            # Generate response from Gemini
            response = self.model.generate_content(full_prompt)

            # Log the interaction
            logger.info(
                f"Chatbot interaction by {request.user.username}: {user_message[:50]}..."
            )

            return Response(
                {
                    "success": True,
                    "response": response.text,
                    "user_message": user_message,
                    "timestamp": timezone.now(),
                },
                status=status.HTTP_200_OK,
            )

        except Exception as e:
            logger.error(f"Chatbot error for user {request.user.username}: {str(e)}")
            return Response(
                {
                    "success": False,
                    "error": "Estoy teniendo problemas para responder en este momento.",
                    "debug_error": str(e),  # Remove this in production
                },
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )


class FirstNameView(APIView):
    """Extract just the first name from user's full name"""

    permission_classes = [IsAuthenticated]

    def get(self, request):
        try:
            user = request.user
            full_name = user.full_name or ""

            # Extract first name (first word before space)
            first_name = full_name.split()[0] if full_name.strip() else ""

            logger.info(f"First name extracted for {user.username}: {first_name}")

            return Response(
                {
                    "success": True,
                    "first_name": first_name,
                    "full_name": user.full_name,
                    "user_id": user.id,
                },
                status=status.HTTP_200_OK,
            )

        except Exception as e:
            logger.error(
                f"Error extracting first name for user {request.user.username}: {str(e)}"
            )
            return Response(
                {
                    "success": False,
                    "error": "Unable to extract first name",
                    "debug_error": str(e),
                },
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )
