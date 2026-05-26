from django.contrib.auth.hashers import check_password, make_password
from django.db import models


class UserGender(models.TextChoices):
    MALE = 'male', 'Laki-laki'
    FEM = 'fem', 'Perempuan'


class MutabaahNote(models.TextChoices):
    ZIYADAH = 'ziyadah', 'Ziyadah'
    MURAJAAH = 'murajaah', "Muraja'ah"


class AuthAccountMixin:
    """Agar instance guru/murid kompatibel dengan DRF IsAuthenticated."""

    @property
    def is_authenticated(self):
        return True

    @property
    def is_anonymous(self):
        return False

    def set_password(self, raw_password):
        self.password_2 = make_password(raw_password)

    def check_password(self, raw_password):
        return check_password(raw_password, self.password_2)


class Guru(AuthAccountMixin, models.Model):
    nama = models.CharField(max_length=100)
    gender = models.CharField(max_length=10, choices=UserGender.choices)
    email = models.EmailField(max_length=100, unique=True)
    password_2 = models.CharField(max_length=255)

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


class Halaqoh(models.Model):
    nama = models.CharField(max_length=100)
    gender = models.CharField(max_length=10, choices=UserGender.choices)
    guru = models.OneToOneField(
        Guru,
        on_delete=models.CASCADE,
        related_name='halaqoh',
        db_column='guru_id',
    )

    class Meta:
        db_table = 'halaqoh'

    def __str__(self):
        return self.nama


class Murid(AuthAccountMixin, models.Model):
    nama = models.CharField(max_length=100)
    gender = models.CharField(max_length=10, choices=UserGender.choices)
    email = models.EmailField(max_length=100, unique=True)
    password_2 = models.CharField(max_length=255)
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
