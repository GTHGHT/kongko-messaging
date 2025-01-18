import 'package:flutter/material.dart';
import 'package:messaging_app_update/services/access_services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../components/update_bottom_sheet.dart';
import '../services/storage_services.dart';
import '../utils/bottom_nav_bar_data.dart';
import '../utils/image_data.dart';

class UpdateAccountScreen extends StatelessWidget {
  const UpdateAccountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ubah Data Akun"),
      ),
      body: ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () async {
                var status = await Permission.storage.status;
                print(status);
                if (status != PermissionStatus.granted) {
                  Map<Permission, PermissionStatus> statuses = await [
                    Permission.storage,
                    Permission.camera,
                  ].request();
                }
                await context.read<ImageData>().showImagePickerDialog(context);
                context
                    .read<AccessServices>()
                    .changeImage(context.read<ImageData>().image);
                showDialog(
                    context: context,
                    builder: (context) {
                      if (context.watch<AccessServices>().loading) {
                        return AlertDialog(
                          title: const Text("Mengubah Gambar..."),
                          content: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              CircularProgressIndicator(),
                            ],
                          ),
                        );
                      } else {
                        Navigator.pop(context);
                        return const SizedBox();
                      }
                    });
              },
              child: CircleAvatar(
                radius: 64,
                child: ClipOval(
                  child: context.watch<ImageData>().image != null
                      ? Image.file(context.watch<ImageData>().image!)
                      : context.watch<AccessServices>().userModel.image.isEmpty
                          ? Image.asset("images/default_profile.png")
                          : FutureBuilder<String>(
                              future: StorageService.getImageLink(context
                                  .read<AccessServices>()
                                  .userModel
                                  .image),
                              builder: (_, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                return Image(
                                  image: NetworkImage(snapshot.data ?? ""),
                                );
                              },
                            ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text("Nama"),
              subtitle:
                  Text(context.watch<AccessServices>().userModel.username),
              trailing: const Icon(Icons.edit),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: UpdateBottomSheet(
                        initialValue:
                            context.read<AccessServices>().userModel.username,
                        loading: context.watch<AccessServices>().loading,
                        title: 'Ubah Nama',
                        onPressed: (ctx, value) async {
                          if (value.isNotEmpty) {
                            await ctx
                                .read<AccessServices>()
                                .changeUsername(value);
                          }
                          Navigator.pop(ctx);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.alternate_email),
              title: const Text("Email"),
              subtitle: Text(context.watch<AccessServices>().userModel.email),
              trailing: const Icon(Icons.edit),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: UpdateBottomSheet(
                        loading: context.watch<AccessServices>().loading,
                        title: "Ubah Email",
                        initialValue:
                            context.read<AccessServices>().userModel.email,
                        onPressed: (ctx, value) async {
                          if (value.isNotEmpty &&
                              RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                  .hasMatch(value)) {
                            value = value.toLowerCase();
                            await ctx.read<AccessServices>().changeEmail(value);
                            Navigator.pushNamedAndRemoveUntil(
                                ctx, '/landing', (_) => false);
                            ctx.read<BottomNavBarData>().currentIndex = 0;
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Perubahan Email Berhasil, Silahkan Login Ulang",
                                ),
                              ),
                            );
                          } else {
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}