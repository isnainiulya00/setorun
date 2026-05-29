from django.contrib.auth.password_validation import validate_password
from rest_framework import serializers

from .authentication import get_account_role
from .models import ChatMessage, ChatRoom, Guru, Halaqoh, Murid, Mutabaah, MutabaahNote, UserGender
from .tokens import get_tokens_for_account
from .utils import find_account_by_login


def email_exists(email):
    normalized = email.lower()
    return (
        Guru.objects.filter(email__iexact=normalized).exists()
        or Murid.objects.filter(email__iexact=normalized).exists()
    )


class HalaqohSerializer(serializers.ModelSerializer):
    name = serializers.CharField(source='nama', read_only=True)
    guru_name = serializers.CharField(source='guru.nama', read_only=True)

    class Meta:
        model = Halaqoh
        fields = ['id', 'nama', 'name', 'gender', 'jadwal', 'guru_name']


class AccountSerializer(serializers.Serializer):
    id = serializers.IntegerField()
    email = serializers.EmailField()
    full_name = serializers.CharField()
    nama = serializers.CharField()
    gender = serializers.CharField()
    role = serializers.CharField()
    role_display = serializers.CharField()
    halaqoh = serializers.IntegerField(allow_null=True)
    halaqoh_detail = HalaqohSerializer(allow_null=True)

    @staticmethod
    def from_account(account):
        role = get_account_role(account)
        halaqoh = getattr(account, 'halaqoh', None)
        if isinstance(account, Guru):
            try:
                halaqoh = account.halaqoh
            except Halaqoh.DoesNotExist:
                halaqoh = None

        return {
            'id': account.pk,
            'email': account.email,
            'full_name': account.nama,
            'nama': account.nama,
            'gender': account.gender,
            'role': role,
            'role_display': 'Guru' if role == 'teacher' else 'Murid',
            'halaqoh': halaqoh.pk if halaqoh else None,
            'halaqoh_detail': HalaqohSerializer(halaqoh).data if halaqoh else None,
        }


class MuridRegisterSerializer(serializers.Serializer):
    email = serializers.EmailField()
    full_name = serializers.CharField(max_length=100)
    gender = serializers.ChoiceField(choices=UserGender.choices)
    password = serializers.CharField(write_only=True, validators=[validate_password])
    password_confirm = serializers.CharField(write_only=True)
    halaqoh_id = serializers.PrimaryKeyRelatedField(
        queryset=Halaqoh.objects.all(),
        source='halaqoh',
    )

    def validate_email(self, value):
        if email_exists(value):
            raise serializers.ValidationError('Email sudah terdaftar.')
        return value.lower()

    def validate(self, attrs):
        if attrs['password'] != attrs.pop('password_confirm'):
            raise serializers.ValidationError(
                {'password_confirm': 'Konfirmasi kata sandi tidak cocok.'}
            )
        return attrs

    def create(self, validated_data):
        murid = Murid(
            nama=validated_data['full_name'].strip(),
            gender=validated_data['gender'],
            email=validated_data['email'],
            halaqoh=validated_data['halaqoh'],
        )
        murid.set_password(validated_data['password'])
        murid.save()
        return murid


class LoginSerializer(serializers.Serializer):
    email = serializers.CharField(required=False, allow_blank=True)
    login = serializers.CharField(required=False, allow_blank=True)
    password = serializers.CharField(write_only=True)

    def validate(self, attrs):
        login_value = (attrs.get('login') or attrs.get('email') or '').strip()
        password = attrs['password']
        account = find_account_by_login(login_value)

        if account is None or not account.check_password(password):
            raise serializers.ValidationError(
                {'detail': 'Email/nama atau kata sandi salah.'}
            )

        tokens = get_tokens_for_account(account)
        attrs['account'] = account
        attrs['tokens'] = tokens
        return attrs


class ProfileUpdateSerializer(serializers.Serializer):
    full_name = serializers.CharField(max_length=100, required=False)
    nama = serializers.CharField(max_length=100, required=False)
    email = serializers.EmailField(required=False)
    gender = serializers.ChoiceField(choices=UserGender.choices, required=False)

    def validate_email(self, value):
        instance = self.context['account']
        if email_exists(value) and instance.email.lower() != value.lower():
            raise serializers.ValidationError('Email sudah digunakan.')
        return value.lower()

    def update(self, instance, validated_data):
        nama = validated_data.pop('full_name', None) or validated_data.pop('nama', None)
        if nama is not None:
            instance.nama = nama.strip()

        email = validated_data.get('email')
        if email is not None:
            instance.email = email.lower()

        if 'gender' in validated_data:
            instance.gender = validated_data['gender']

        instance.save()
        return instance


class MutabaahSerializer(serializers.ModelSerializer):
    murid_nama = serializers.CharField(source='murid.nama', read_only=True)
    note_display = serializers.CharField(source='get_note_display', read_only=True)
    judul = serializers.SerializerMethodField()
    status = serializers.SerializerMethodField()

    class Meta:
        model = Mutabaah
        fields = [
            'id',
            'murid',
            'murid_nama',
            'tanggal',
            'nama_surah',
            'ayat',
            'note',
            'note_display',
            'keterangan',
            'judul',
            'status',
        ]
        read_only_fields = ['tanggal']

    def get_judul(self, obj):
        return f'{obj.nama_surah} {obj.ayat}'

    def get_status(self, obj):
        return 'Selesai'


class MutabaahCreateUpdateSerializer(serializers.ModelSerializer):
    ayat_mulai = serializers.IntegerField(write_only=True, required=False)
    ayat_selesai = serializers.IntegerField(write_only=True, required=False)

    class Meta:
        model = Mutabaah
        fields = [
            'id',
            'murid',
            'nama_surah',
            'ayat',
            'note',
            'keterangan',
            'ayat_mulai',
            'ayat_selesai',
        ]

    def validate(self, attrs):
        mulai = attrs.pop('ayat_mulai', None)
        selesai = attrs.pop('ayat_selesai', None)
        if mulai is not None and selesai is not None:
            attrs['ayat'] = f'{mulai}-{selesai}'
        elif not attrs.get('ayat'):
            raise serializers.ValidationError({'ayat': 'Ayat wajib diisi.'})
        return attrs


class MuridBriefSerializer(serializers.ModelSerializer):
    class Meta:
        model = Murid
        fields = ['id', 'nama', 'email', 'gender']


class ChatMessageSerializer(serializers.ModelSerializer):
    is_me = serializers.SerializerMethodField()
    sender_name = serializers.SerializerMethodField()
    time_display = serializers.SerializerMethodField()

    class Meta:
        model = ChatMessage
        fields = [
            'id',
            'room',
            'sender_type',
            'sender_id',
            'sender_name',
            'text',
            'created_at',
            'time_display',
            'is_me',
        ]
        read_only_fields = ['room', 'sender_type', 'sender_id', 'created_at']

    def get_is_me(self, obj):
        request = self.context.get('request')
        if not request or not request.user:
            return False
        user = request.user
        if isinstance(user, Guru):
            return obj.sender_type == 'guru' and obj.sender_id == user.pk
        if isinstance(user, Murid):
            return obj.sender_type == 'murid' and obj.sender_id == user.pk
        return False

    def get_sender_name(self, obj):
        if obj.sender_type == 'guru':
            guru = Guru.objects.filter(pk=obj.sender_id).first()
            return guru.nama if guru else 'Guru'
        murid = Murid.objects.filter(pk=obj.sender_id).first()
        return murid.nama if murid else 'Murid'

    def get_time_display(self, obj):
        return obj.created_at.strftime('%H:%M')


class ChatConversationSerializer(serializers.Serializer):
    room_id = serializers.IntegerField()
    murid_id = serializers.IntegerField()
    murid_nama = serializers.CharField()
    last_message = serializers.CharField(allow_blank=True)
    last_time = serializers.CharField(allow_blank=True)
    unread_count = serializers.IntegerField()


class ChatSendSerializer(serializers.Serializer):
    text = serializers.CharField(max_length=2000)
    murid_id = serializers.IntegerField(required=False)

    def validate_text(self, value):
        value = value.strip()
        if not value:
            raise serializers.ValidationError('Pesan tidak boleh kosong.')
        return value
