from django.contrib.auth.models import User
from django.db import models


class UserGender(models.TextChoices):
    MALE = 'male', 'Laki-laki'
    FEM = 'fem', 'Perempuan'


class MutabaahNote(models.TextChoices):
    ZIYADAH = 'ziyadah', 'Ziyadah'
    MURAJAAH = 'murajaah', "Muraja'ah"


class SenderType(models.TextChoices):
    GURU = 'guru', 'Guru'
    MURID = 'murid', 'Murid'



class Guru(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='guru_profile')
    nama = models.CharField(max_length=100)
    gender = models.CharField(max_length=10, choices=UserGender.choices)

    class Meta:
        db_table = 'guru'

    def __str__(self):
        return self.nama

    @property
    def is_teacher(self):
        return True

    @property
    def is_student(self):
        return False

    @property
    def is_authenticated(self):
        return True


class Halaqoh(models.Model):
    nama = models.CharField(max_length=100)
    gender = models.CharField(max_length=10, choices=UserGender.choices)
    jadwal = models.CharField(max_length=200, blank=True, default='')
    guru = models.ForeignKey(
        Guru,
        on_delete=models.CASCADE,
        related_name='halaqoh_list', 
        db_column='guru_id',
    )
    class Meta:
        db_table = 'halaqoh'


class Murid(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='murid_profile')
    nama = models.CharField(max_length=100)
    gender = models.CharField(max_length=10, choices=UserGender.choices)
    status_join = models.CharField(max_length=20, default='pending')
    halaqoh = models.ForeignKey(
        Halaqoh,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='murid_list',
        db_column='halaqoh_id',
    )
    
    class Meta:
        db_table = 'murid'

    def __str__(self):
        return self.nama

    @property
    def is_teacher(self):
        return False

    @property
    def is_student(self):
        return True

    @property
    def is_authenticated(self):
        return True


class Mutabaah(models.Model):
    murid = models.ForeignKey(
        Murid,
        on_delete=models.CASCADE,
        related_name='mutabaah_list',
        db_column='murid_id',
    )
    tanggal = models.DateTimeField(auto_now_add=True)
    nama_surah = models.CharField(max_length=100)
    ayat = models.CharField(max_length=50)
    note = models.CharField(max_length=20, choices=MutabaahNote.choices)
    keterangan = models.CharField(max_length=255, blank=True, null=True)

    class Meta:
        db_table = 'mutabaah'
        ordering = ['-tanggal']

    def __str__(self):
        return f'{self.murid.nama} - {self.nama_surah}'


class ChatRoom(models.Model):
    murid = models.OneToOneField(
        Murid,
        on_delete=models.CASCADE,
        related_name='chat_room',
        db_column='murid_id',
    )
    halaqoh = models.ForeignKey(
        Halaqoh,
        on_delete=models.CASCADE,
        related_name='chat_rooms',
        db_column='halaqoh_id',
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'chat_room'

    def __str__(self):
        return f'Chat {self.murid.nama}'


class ChatMessage(models.Model):
    room = models.ForeignKey(
        ChatRoom,
        on_delete=models.CASCADE,
        related_name='messages',
        db_column='room_id',
    )
    sender_type = models.CharField(max_length=10, choices=SenderType.choices)
    sender_id = models.PositiveIntegerField()
    text = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'chat_message'
        ordering = ['created_at']

    def __str__(self):
        return f'{self.sender_type}: {self.text[:30]}'