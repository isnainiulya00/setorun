from django.core.management.base import BaseCommand
from django.utils import timezone

from api.models import (
    ChatRoom,
    Guru,
    Halaqoh,
    Murid,
    Mutabaah,
    MutabaahNote,
    UserGender,
)
from api.utils import get_or_create_chat_room


class Command(BaseCommand):
    help = 'Seed akun isna (guru) & ulyatul faizah (murid) + data demo'

    def handle(self, *args, **options):
        guru, created = Guru.objects.update_or_create(
            email='isna@setorun.id',
            defaults={
                'nama': 'isna',
                'gender': UserGender.FEM,
            },
        )
        guru.set_password('isna12345')
        guru.save()
        self.stdout.write(
            self.style.SUCCESS('Guru isna: login "isna" atau isna@setorun.id / isna12345')
        )

        halaqoh, _ = Halaqoh.objects.update_or_create(
            guru=guru,
            defaults={
                'nama': 'Halaqoh Al-Fatih',
                'gender': UserGender.FEM,
                'jadwal': 'Senin & Rabu, 08:00–10:00 WIB',
            },
        )

        murid, _ = Murid.objects.update_or_create(
            email='ulyatul@setorun.id',
            defaults={
                'nama': 'ulyatul faizah',
                'gender': UserGender.FEM,
                'halaqoh': halaqoh,
            },
        )
        murid.set_password('ulyatul12345')
        murid.save()
        self.stdout.write(
            self.style.SUCCESS(
                'Murid ulyatul faizah: login "ulyatul faizah" atau '
                'ulyatul@setorun.id / ulyatul12345'
            )
        )

        get_or_create_chat_room(murid)

        Mutabaah.objects.get_or_create(
            murid=murid,
            nama_surah='Al-Baqarah',
            ayat='1-5',
            defaults={
                'note': MutabaahNote.ZIYADAH,
                'keterangan': 'Lancar, perlu perbaikan makhraj',
            },
        )
        Mutabaah.objects.get_or_create(
            murid=murid,
            nama_surah='An-Nas',
            ayat='1-6',
            defaults={
                'note': MutabaahNote.MURAJAAH,
                'keterangan': 'Murajaah juz 30',
            },
        )

        self.stdout.write(self.style.SUCCESS('Seed selesai.'))
