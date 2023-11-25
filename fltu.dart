import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class Homex extends StatefulWidget {
  const Homex({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Homex> {
  String serverIP = '172.16.202.176'; // Update with your Flask server's IP
  int serverPort = 5000;
  String output = 'Initial Output';

  PlatformFile? resumeFile; // nullable PlatformFile
  PlatformFile? jdFile; // nullable PlatformFile

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Python-Flutter Integration')),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf'],
                  );

                  if (result != null && result.files.isNotEmpty) {
                    // Convert PlatformFile to File
                    resumeFile = result.files.first;
                    await moveFileToAppUploads(resumeFile!.path!);
                    print('Resume File picked and moved');
                  } else {
                    print('No Resume file picked');
                  }
                },
                child: Text(
                  'Upload Resume',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf'],
                  );

                  if (result != null && result.files.isNotEmpty) {
                    // Convert PlatformFile to File
                    jdFile = result.files.first;
                    await moveFileToAppUploads(jdFile!.path!);
                    print('JD File picked and moved');
                  } else {
                    print('No JD file picked');
                  }
                },
                child: Text(
                  'Upload JD',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (resumeFile != null && jdFile != null) {
                    try {
                      // Create a multipart request
                      var request = http.MultipartRequest(
                        'POST',
                        Uri.parse('http://$serverIP:$serverPort/calculate_similarity'),
                      );

                      // Attach files to the request
                      request.files.add(
                        http.MultipartFile.fromBytes(
                          'resume',
                          await File(resumeFile!.path!).readAsBytes(),
                          filename: 'resume.pdf',
                        ),
                      );

                      request.files.add(
                        http.MultipartFile.fromBytes(
                          'jd',
                          await File(jdFile!.path!).readAsBytes(),
                          filename: 'jd.pdf',
                        ),
                      );

                      // Send the request
                      var response = await request.send();

                      // Check the response
                      if (response.statusCode == 200) {
                        // Decode the response
                        var decoded = jsonDecode(await response.stream.bytesToString());

                        // Update the output
                        setState(() {
                          output = 'Match Percentage: ${decoded['match_percentage']}%';
                        });
                      } else {
                        print('Request failed with status: ${response.statusCode}');
                      }
                    } catch (e) {
                      print('Error: $e');
                    }
                  } else {
                    print('Please upload both Resume and JD files');
                  }
                },
                child: Text(
                  'Calculate Similarity',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              SizedBox(height: 20),
              Text(
                output,
                style: TextStyle(fontSize: 20, color: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> moveFileToAppUploads(String filePath) async {
    try {
      // Get the documents directory using path_provider
      //Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String appUploadsPath = '/storage/emulated/0/Download/App_uploads';
      Directory(appUploadsPath).createSync(recursive: true);

      // Move the file to app_uploads directory
      File file = File(filePath);
      String newFilePath = '$appUploadsPath/${file.uri.pathSegments.last}';
      await file.rename(newFilePath);
    } catch (e) {
      print('Error moving file: $e');
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: Homex(),
  ));
}
