import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageDecoration = PageDecoration(
      imagePadding: const EdgeInsets.all(24),
      bodyAlignment: Alignment.center,
      titleTextStyle:
          Theme.of(context).textTheme.titleLarge ?? const TextStyle(),
      bodyTextStyle:
          Theme.of(context).textTheme.bodyMedium ?? const TextStyle(),
      bodyPadding: const EdgeInsets.symmetric(vertical: 20),
    );

    return SafeArea(
      child: IntroductionScreen(
        dotsDecorator: DotsDecorator(
          color: Theme.of(context).colorScheme.onBackground,
          activeColor: Theme.of(context).colorScheme.primary,
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
          ),
          activeSize: const Size(18, 9),
        ),
        skip: Text(
          "Skip",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        showSkipButton: true,
        next: Text(
          "Selanjutnya",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        showNextButton: true,
        done: Text(
          "Selesai",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        showDoneButton: true,
        onSkip: () {
          Navigator.pushReplacementNamed(context, '/access');
        },
        onDone: () {
          Navigator.pushReplacementNamed(context, '/access');
        },
        pages: [
          PageViewModel(
            title: "Hallo, Selamat Datang Di Aplikasi Kongko",
            body:
                "Aplikasi pesan online karya anak bangsa yang bisa diakses kapanpun dan dimanapun.",
            image: Theme.of(context).brightness == Brightness.light
                ? Image.asset("images/app_logo.png")
                : Image.asset("images/app_logo_b.png"),
            decoration: pageDecoration,
          ),
          // TODO: Ubah Title Sama Bodynya
          PageViewModel(
            title: "Simpel",
            body: "Sederhana dan mudah untuk Anda gunakan.",
            image: Theme.of(context).brightness == Brightness.light
                ? Image.asset("images/landing_one.png")
                : Image.asset("images/landing_one_b.png"),
            decoration: pageDecoration,
          ),
          // TODO: Ubah Title Sama Bodynya
          PageViewModel(
            title: "Cepat",
            body: "Mengirim pesan lebih cepat dari aplikasi lain.",
            image: Theme.of(context).brightness == Brightness.light
                ? Image.asset("images/landing_two.png")
                : Image.asset("images/landing_two_b.png"),
            decoration: pageDecoration,
          ),
          // TODO: Ubah Title Sama Bodynya
          PageViewModel(
            title: "Memiliki Fitur Unik",
            body:
                "Kirim pesan ke siapapun tanpa menyimpan nomor terlebih dahulu.",
            image: Theme.of(context).brightness == Brightness.light
                ? Image.asset("images/landing_three.png")
                : Image.asset("images/landing_three_b.png"),
            decoration: pageDecoration,
          ),
        ],
      ),
    );

    // return Scaffold(
    //   body: SafeArea(
    //     child: ConstrainedBox(
    //       constraints: const BoxConstraints.expand(),
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: [
    //           Image.asset(
    //             "images/app_logo.png",
    //             width: MediaQuery.of(context).size.width / 2,
    //             fit: BoxFit.fitWidth,
    //           ),
    //           const SizedBox(
    //             height: 80,
    //           ),
    //           Text(
    //             "Selamat Datang Ke Kongko",
    //             style: Theme.of(context).textTheme.titleLarge,
    //           ),
    //           const SizedBox(
    //             height: 24,
    //           ),
    //           SizedBox(
    //             width: (MediaQuery.of(context).size.width / 6) * 5,
    //             child: Text(
    //               "Menghubungkan Yang Jauh, Memutuskan Yang Dekat.",
    //               softWrap: true,
    //               textAlign: TextAlign.center,
    //               style: Theme.of(context).textTheme.bodyMedium,
    //             ),
    //           ),
    //           const SizedBox(
    //             height: 80,
    //           ),
    //           ElevatedButton(
    //             onPressed: () {
    //               Navigator.of(context).pushReplacementNamed("/access");
    //             },
    //             child: Text(
    //               "Mulai Aplikasi",
    //               style: Theme.of(context).primaryTextTheme.bodyLarge,
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }
}
