from rest_framework import generics, permissions, status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework import status
from .models import Guru, Halaqoh


from .models import ChatMessage, ChatRoom, Guru, Halaqoh, Murid, Mutabaah, SenderType
from .serializers import (
    AccountSerializer,
    ChatConversationSerializer,
    ChatMessageSerializer,
    ChatSendSerializer,
    HalaqohSerializer,
    LoginSerializer,
    MuridBriefSerializer,
    MuridRegisterSerializer,
    MutabaahCreateUpdateSerializer,
    MutabaahSerializer,
    ProfileUpdateSerializer,
)
from .utils import find_account_by_login, get_guru_halaqoh, get_or_create_chat_room


def get_user_profile(user):
    if hasattr(user, 'guru_profile'):
        return user.guru_profile
    if hasattr(user, 'murid_profile'):
        return user.murid_profile
    return None


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
        get_or_create_chat_room(murid)
        login = LoginSerializer(
            data={
                # PERUBAHAN: email sekarang ada di murid.user.email
                'login': murid.user.email, 
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
        profile = get_user_profile(request.user)
        return Response(AccountSerializer.from_account(profile))

    def patch(self, request):
        profile = get_user_profile(request.user)
        serializer = ProfileUpdateSerializer(
            data=request.data,
            partial=True,
            context={'account': profile},
        )
        serializer.is_valid(raise_exception=True)
        account = serializer.update(profile, serializer.validated_data)
        return Response(AccountSerializer.from_account(account))


class MyHalaqohView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        profile = get_user_profile(request.user)
        halaqoh = None

        if hasattr(request.user, 'murid_profile'):
            halaqoh = profile.halaqoh
        elif hasattr(request.user, 'guru_profile'):
            halaqoh = get_guru_halaqoh(profile)

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


class MuridHomeView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        if not hasattr(request.user, 'murid_profile'):
            return Response({'detail': 'Hanya untuk murid.'}, status=403)

        murid = request.user.murid_profile
        halaqoh = murid.halaqoh
        mutabaah_qs = Mutabaah.objects.filter(murid=murid).order_by('-tanggal')[:10]
        riwayat = MutabaahSerializer(mutabaah_qs, many=True).data
        total = Mutabaah.objects.filter(murid=murid).count()
        progress = min(total * 5, 100) / 100.0

        return Response({
            'nama': murid.nama,
            'halaqoh_nama': halaqoh.nama if halaqoh else '',
            'guru_nama': halaqoh.guru.nama if halaqoh else '',
            'jadwal': halaqoh.jadwal if halaqoh else 'Belum ada jadwal',
            'progress_percent': round(progress * 100),
            'riwayat': riwayat,
        })


class MutabaahListCreateView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        if hasattr(request.user, 'murid_profile'):
            qs = Mutabaah.objects.filter(murid=request.user.murid_profile).select_related('murid')
        elif hasattr(request.user, 'guru_profile'):
            halaqoh = get_guru_halaqoh(request.user.guru_profile)
            if not halaqoh:
                return Response([])
            qs = Mutabaah.objects.filter(murid__halaqoh=halaqoh).select_related('murid')
        else:
            return Response([])
            
        serializer = MutabaahSerializer(qs.order_by('-tanggal'), many=True)
        return Response(serializer.data)

    def post(self, request):
        if not hasattr(request.user, 'guru_profile'):
            return Response({'detail': 'Hanya guru yang dapat menambah mutabaah.'}, status=403)

        guru = request.user.guru_profile
        halaqoh = get_guru_halaqoh(guru)
        if not halaqoh:
            return Response({'detail': 'Guru belum punya halaqoh.'}, status=400)

        serializer = MutabaahCreateUpdateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        murid = serializer.validated_data['murid']
        if murid.halaqoh_id != halaqoh.id:
            return Response({'detail': 'Murid bukan dari halaqoh Anda.'}, status=403)

        mutabaah = serializer.save()
        return Response(
            MutabaahSerializer(mutabaah).data,
            status=status.HTTP_201_CREATED,
        )


class MutabaahDetailView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self, pk, guru):
        try:
            obj = Mutabaah.objects.select_related('murid').get(pk=pk)
        except Mutabaah.DoesNotExist:
            return None
        halaqoh = get_guru_halaqoh(guru)
        if not halaqoh or obj.murid.halaqoh_id != halaqoh.id:
            return None
        return obj

    def patch(self, request, pk):
        if not hasattr(request.user, 'guru_profile'):
            return Response({'detail': 'Hanya guru.'}, status=403)
            
        obj = self.get_object(pk, request.user.guru_profile)
        if not obj:
            return Response({'detail': 'Tidak ditemukan.'}, status=404)
        serializer = MutabaahCreateUpdateSerializer(obj, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        mutabaah = serializer.save()
        return Response(MutabaahSerializer(mutabaah).data)

    def delete(self, request, pk):
        if not hasattr(request.user, 'guru_profile'):
            return Response({'detail': 'Hanya guru.'}, status=403)
            
        obj = self.get_object(pk, request.user.guru_profile)
        if not obj:
            return Response({'detail': 'Tidak ditemukan.'}, status=404)
        obj.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


class GuruMuridListView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        if not hasattr(request.user, 'guru_profile'):
            return Response({'detail': 'Hanya guru.'}, status=403)
            
        halaqoh = get_guru_halaqoh(request.user.guru_profile)
        if not halaqoh:
            return Response([])
        murid_list = Murid.objects.filter(halaqoh=halaqoh).order_by('nama')
        return Response(MuridBriefSerializer(murid_list, many=True).data)


class ChatConversationListView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        if not hasattr(request.user, 'guru_profile'):
            return Response({'detail': 'Hanya guru.'}, status=403)

        halaqoh = get_guru_halaqoh(request.user.guru_profile)
        if not halaqoh:
            return Response([])

        conversations = []
        for murid in Murid.objects.filter(halaqoh=halaqoh).order_by('nama'):
            room = get_or_create_chat_room(murid)
            if not room:
                continue
            last_msg = room.messages.order_by('-created_at').first()
            conversations.append({
                'room_id': room.id,
                'murid_id': murid.id,
                'murid_nama': murid.nama,
                'last_message': last_msg.text if last_msg else 'Belum ada pesan',
                'last_time': last_msg.created_at.strftime('%H:%M') if last_msg else '',
                'unread_count': 0,
            })

        return Response(conversations)


class ChatMessageListView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def _get_room(self, request, murid_id=None):
        if hasattr(request.user, 'murid_profile'):
            return get_or_create_chat_room(request.user.murid_profile)
            
        if hasattr(request.user, 'guru_profile') and murid_id:
            guru = request.user.guru_profile
            halaqoh = get_guru_halaqoh(guru)
            if not halaqoh:
                return None
            try:
                murid = Murid.objects.get(pk=murid_id, halaqoh=halaqoh)
            except Murid.DoesNotExist:
                return None
            return get_or_create_chat_room(murid)
        return None

    def get(self, request):
        murid_id = request.query_params.get('murid_id')
        room = self._get_room(request, int(murid_id) if murid_id else None)
        if not room:
            return Response({'detail': 'Room chat tidak ditemukan.'}, status=404)

        messages = room.messages.all()
        serializer = ChatMessageSerializer(
            messages, many=True, context={'request': request}
        )
        return Response({
            'room_id': room.id,
            'murid_id': room.murid_id,
            'murid_nama': room.murid.nama,
            'guru_nama': room.halaqoh.guru.nama,
            'messages': serializer.data,
        })


class ChatSendView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = ChatSendSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        text = serializer.validated_data['text']

        if hasattr(request.user, 'murid_profile'):
            murid = request.user.murid_profile
            room = get_or_create_chat_room(murid)
            if not room:
                return Response({'detail': 'Murid belum terdaftar halaqoh.'}, status=400)
            msg = ChatMessage.objects.create(
                room=room,
                sender_type=SenderType.MURID,
                sender_id=murid.pk,
                text=text,
            )
        elif hasattr(request.user, 'guru_profile'):
            guru = request.user.guru_profile
            murid_id = serializer.validated_data.get('murid_id')
            if not murid_id:
                return Response({'detail': 'murid_id wajib untuk guru.'}, status=400)
            
            halaqoh = get_guru_halaqoh(guru)
            try:
                murid = Murid.objects.get(pk=murid_id, halaqoh=halaqoh)
            except Murid.DoesNotExist:
                return Response({'detail': 'Murid tidak ditemukan.'}, status=404)
            room = get_or_create_chat_room(murid)
            msg = ChatMessage.objects.create(
                room=room,
                sender_type=SenderType.GURU,
                sender_id=guru.pk,
                text=text,
            )
        else:
            return Response({'detail': 'Unauthorized.'}, status=403)

        return Response(
            ChatMessageSerializer(msg, context={'request': request}).data,
            status=status.HTTP_201_CREATED,
        )

class CreateHalaqohView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        guru = Guru.objects.filter(user=request.user).first()
        if not guru:
            return Response(
                {'error': 'Akses ditolak. Hanya Guru yang dapat membuat Halaqah.'}, 
                status=status.HTTP_403_FORBIDDEN
            )
            

        nama = request.data.get('nama')
        jadwal = request.data.get('jadwal', '')

        if not nama:
            return Response(
                {'error': 'Nama halaqah wajib diisi.'}, 
                status=status.HTTP_400_BAD_REQUEST
            )

        halaqoh = Halaqoh.objects.create(
            nama=nama,
            jadwal=jadwal,
            guru=guru,
            gender=guru.gender 
        )

        return Response({
            'message': 'Halaqah berhasil dibuat!',
            'halaqoh_id': halaqoh.id,
            'nama': halaqoh.nama,
            'gender': halaqoh.gender
        }, status=status.HTTP_201_CREATED)