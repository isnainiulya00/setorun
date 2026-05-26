from django.contrib.auth.password_validation import validate_password
from rest_framework import serializers

from .authentication import get_account_role
from .models import Guru, Halaqoh, Murid, Mutabaah, MutabaahNote, UserGender
from .tokens import get_tokens_for_account


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
        fields = ['id', 'nama', 'name', 'gender', 'guru_name']


class AccountSerializer(serializers.Serializer):
    """Response profil/login — kompatibel dengan Flutter (full_name, role)."""

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

        data = {
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
        return data


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
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)

    def validate(self, attrs):
        email = attrs['email'].lower()
        password = attrs['password']
        account = None

        try:
            account = Guru.objects.select_related('halaqoh').get(email__iexact=email)
        except Guru.DoesNotExist:
            try:
                account = Murid.objects.select_related(
                    'halaqoh', 'halaqoh__guru'
                ).get(email__iexact=email)
            except Murid.DoesNotExist:
                pass

        if account is None or not account.check_password(password):
            raise serializers.ValidationError(
                {'detail': 'Email atau kata sandi salah.'}
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
            email = email.lower()
            if email_exists(email) and instance.email.lower() != email:
                raise serializers.ValidationError(
                    {'email': 'Email sudah digunakan.'}
                )
            instance.email = email

        if 'gender' in validated_data:
            instance.gender = validated_data['gender']

        instance.save()
        return instance


class MutabaahSerializer(serializers.ModelSerializer):
    murid_nama = serializers.CharField(source='murid.nama', read_only=True)
    note_display = serializers.CharField(source='get_note_display', read_only=True)

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
        ]
        read_only_fields = ['tanggal']
