from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import Guru, Halaqoh, Murid
from .serializers import (
    AccountSerializer,
    HalaqohSerializer,
    LoginSerializer,
    MuridRegisterSerializer,
    ProfileUpdateSerializer,
)


class LoginView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        account = serializer.validated_data['account']
        tokens = serializer.validated_data['tokens']
        return Response({
            **tokens,
            'user': AccountSerializer.from_account(account),
        })


class StudentRegisterView(generics.CreateAPIView):
    serializer_class = MuridRegisterSerializer
    permission_classes = [permissions.AllowAny]

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        murid = serializer.save()
        login = LoginSerializer(
            data={
                'email': murid.email,
                'password': request.data.get('password'),
            }
        )
        login.is_valid(raise_exception=True)
        return Response(
            {
                **login.validated_data['tokens'],
                'user': AccountSerializer.from_account(murid),
            },
            status=status.HTTP_201_CREATED,
        )


class LogoutView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        return Response({'detail': 'Berhasil logout.'}, status=status.HTTP_200_OK)


class ProfileView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        return Response(AccountSerializer.from_account(request.user))

    def patch(self, request):
        serializer = ProfileUpdateSerializer(
            data=request.data,
            partial=True,
            context={'account': request.user},
        )
        serializer.is_valid(raise_exception=True)
        account = serializer.update(request.user, serializer.validated_data)
        return Response(AccountSerializer.from_account(account))


class MyHalaqohView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        account = request.user
        halaqoh = None

        if isinstance(account, Murid):
            halaqoh = account.halaqoh
        elif isinstance(account, Guru):
            try:
                halaqoh = account.halaqoh
            except Halaqoh.DoesNotExist:
                halaqoh = None

        if halaqoh is None:
            return Response(
                {'detail': 'Anda belum terdaftar di halaqoh.'},
                status=status.HTTP_404_NOT_FOUND,
            )
        return Response(HalaqohSerializer(halaqoh).data)


class HalaqohListView(generics.ListAPIView):
    queryset = Halaqoh.objects.select_related('guru').order_by('nama')
    serializer_class = HalaqohSerializer
    permission_classes = [permissions.AllowAny]
