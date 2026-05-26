from django.core.management.base import BaseCommand

from api.models import Guru, Halaqoh, Murid, UserGender


class Command(BaseCommand):
    help = 'Seed data demo guru, halaqoh, dan murid sesuai skema tabel'

    def handle(self, *args, **options):
        guru, created = Guru.objects.get_or_create(
            email='guru@setorun.id',
            defaults={
                'nama': 'Ustazah Isna',
                'gender': UserGender.FEM,
            },
        )
        if created:
            guru.set_password('guru12345')
            guru.save()
            self.stdout.write(self.style.SUCCESS('Guru demo: guru@setorun.id / guru12345'))
        else:
            self.stdout.write('Guru demo sudah ada.')

        h1, _ = Halaqoh.objects.get_or_create(
            guru=guru,
            defaults={
                'nama': 'Halaqoh Al-Fatih',
                'gender': UserGender.FEM,
            },
        )

        murid, created = Murid.objects.get_or_create(
            email='murid@setorun.id',
            defaults={
                'nama': 'Isnaini',
                'gender': UserGender.FEM,
                'halaqoh': h1,
            },
        )
        if created:
            murid.set_password('murid12345')
            murid.save()
            self.stdout.write(self.style.SUCCESS('Murid demo: murid@setorun.id / murid12345'))
        else:
            self.stdout.write('Murid demo sudah ada.')

        self.stdout.write(self.style.SUCCESS('Seed selesai.'))
