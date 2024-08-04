import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';

class AddAppDialog extends StatelessWidget {
  final List<Application> notSecuredApps;
  final void Function(Application) onAdd;

  AddAppDialog({
    required this.notSecuredApps,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Application'),
      content: Container(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: notSecuredApps.length,
          itemBuilder: (context, index) {
            Application app = notSecuredApps[index];
            return ListTile(
              leading: app is ApplicationWithIcon
                  ? Image.memory(app.icon, width: 40, height: 40)
                  : Icon(Icons.android, size: 40),
              title: Text(app.appName),
              trailing: IconButton(
                icon: Icon(Icons.add, color: Colors.blue),
                onPressed: () {
                  onAdd(app);
                  Navigator.of(context).pop();
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
