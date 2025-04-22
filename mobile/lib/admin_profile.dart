import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const AdminProfileApp());
}

class AdminProfileApp extends StatelessWidget {
  const AdminProfileApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF2E7D32),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          primary: const Color(0xFF2E7D32),
          secondary: const Color(0xFF689F38),
          background: Colors.white,
        ),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: const TextStyle(color: Color(0xFF2E7D32)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2E7D32)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        useMaterial3: true,
      ),
      home: const AdminProfilePage(),
    );
  }
}

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({Key? key}) : super(key: key);

  @override
  _AdminProfilePageState createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  bool _isEditing = false;
  String _profileImageUrl = '';
  bool _isLoading = true;
  User? _currentUser;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Reference to your specific Firebase Storage bucket
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
    bucket: 'gs://smart-waste-management-3041a.appspot.com',
  );

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _getCurrentUser();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentUser() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      _fetchAdminData();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchAdminData() async {
    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_currentUser!.uid)
              .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        setState(() {
          _fullNameController.text = data['name'] ?? '';
          _emailController.text = _currentUser!.email ?? '';
          _phoneController.text = data['phone'] ?? '';
          _addressController.text = data['address'] ?? '';
          _profileImageUrl = data['photoURL'] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _fullNameController.text = _currentUser!.displayName ?? '';
          _emailController.text = _currentUser!.email ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching admin data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85, // Added quality parameter
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });

        // If not in edit mode, toggle to edit mode after picking an image
        if (!_isEditing) {
          _toggleEditMode();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;

    try {
      String filename = path.basename(_selectedImage!.path);
      int dotIndex = filename.indexOf('.');
      String fileExtension =
          dotIndex != -1 && dotIndex < filename.length - 1
              ? filename.substring(dotIndex + 1)
              : 'jpg';

      String storagePath =
          'admin_profile_pictures/${_currentUser!.uid}_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

      // Create storage reference with explicit path
      final Reference storageRef = _storage.ref().child(storagePath);

      // Start upload with metadata
      final SettableMetadata metadata = SettableMetadata(
        contentType: 'image/$fileExtension',
        customMetadata: {'userId': _currentUser!.uid},
      );

      // Upload with metadata and track progress
      UploadTask uploadTask = storageRef.putFile(_selectedImage!, metadata);

      // Monitor upload progress if needed
      uploadTask.snapshotEvents.listen(
        (TaskSnapshot snapshot) {
          print(
            'Upload progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100}%',
          );
        },
        onError: (e) {
          print('Upload error: $e');
        },
      );

      // Wait for upload to complete
      await uploadTask;

      // Get download URL
      String downloadUrl = await storageRef.getDownloadURL();
      print('Image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      throw e;
    }
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _isLoading = true;
        });

        String? photoURL;
        if (_selectedImage != null) {
          try {
            photoURL = await _uploadImage();
            if (photoURL != null) {
              await _currentUser!.updatePhotoURL(photoURL);
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error uploading profile image: $e'),
                backgroundColor: Colors.red,
              ),
            );
            // Continue with other data updates even if image upload fails
          }
        }

        Map<String, dynamic> adminData = {
          'name': _fullNameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
          'role': 'admin', // Always set role as admin in the backend
          'updatedAt': FieldValue.serverTimestamp(),
        };

        if (photoURL != null) {
          adminData['photoURL'] = photoURL;
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .set(adminData, SetOptions(merge: true));

        await _currentUser!.updateDisplayName(_fullNameController.text);

        setState(() {
          _isEditing = false;
          _isLoading = false;
          _selectedImage = null;
          if (photoURL != null) {
            _profileImageUrl = photoURL;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin Profile updated successfully'),
            backgroundColor: Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating admin profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Admin Profile' : 'Admin Profile'),
        centerTitle: true,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: _toggleEditMode,
            )
          else
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: _toggleEditMode,
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.check, size: 20),
              onPressed: _saveProfile,
            ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : (_currentUser == null
                  ? _buildNotLoggedInView()
                  : SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (!_isEditing)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 16),
                              child: Text(
                                'EcoBin Admin Portal',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF2E7D32),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          Container(
                            margin: const EdgeInsets.only(top: 8, bottom: 32),
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 1,
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 60,
                                    backgroundColor: Colors.white,
                                    child: _buildProfileImage(),
                                  ),
                                ),
                                // Camera icon is now visible regardless of edit mode
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          spreadRadius: 1,
                                          blurRadius: 2,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      radius: 18,
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        onPressed: _pickImage,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            alignment: Alignment.centerLeft,
                            margin: const EdgeInsets.only(bottom: 16, left: 4),
                            child: Text(
                              'Admin Information',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).primaryColor,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.08),
                                  spreadRadius: 1,
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _isEditing
                                    ? TextFormField(
                                      controller: _fullNameController,
                                      decoration: const InputDecoration(
                                        labelText: 'Full Name',
                                        prefixIcon: Icon(
                                          Icons.person_outline,
                                          color: Color(0xFF2E7D32),
                                          size: 20,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your full name';
                                        }
                                        return null;
                                      },
                                    )
                                    : _buildProfileField(
                                      Icons.person_outline,
                                      'Full Name',
                                      _fullNameController.text,
                                    ),
                                const SizedBox(height: 24),
                                _isEditing
                                    ? TextFormField(
                                      controller: _emailController,
                                      enabled: false,
                                      decoration: const InputDecoration(
                                        labelText: 'Email Address',
                                        prefixIcon: Icon(
                                          Icons.email_outlined,
                                          color: Color(0xFF2E7D32),
                                          size: 20,
                                        ),
                                      ),
                                      keyboardType: TextInputType.emailAddress,
                                    )
                                    : _buildProfileField(
                                      Icons.email_outlined,
                                      'Email Address',
                                      _emailController.text,
                                    ),
                                const SizedBox(height: 24),
                                _isEditing
                                    ? TextFormField(
                                      controller: _phoneController,
                                      decoration: const InputDecoration(
                                        labelText: 'Phone Number',
                                        prefixIcon: Icon(
                                          Icons.phone_outlined,
                                          color: Color(0xFF2E7D32),
                                          size: 20,
                                        ),
                                      ),
                                      keyboardType: TextInputType.phone,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your phone number';
                                        }
                                        return null;
                                      },
                                    )
                                    : _buildProfileField(
                                      Icons.phone_outlined,
                                      'Phone Number',
                                      _phoneController.text,
                                    ),
                                const SizedBox(height: 24),
                                _isEditing
                                    ? TextFormField(
                                      controller: _addressController,
                                      decoration: const InputDecoration(
                                        labelText: 'Address',
                                        prefixIcon: Icon(
                                          Icons.location_on_outlined,
                                          color: Color(0xFF2E7D32),
                                          size: 20,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your address';
                                        }
                                        return null;
                                      },
                                    )
                                    : _buildProfileField(
                                      Icons.location_on_outlined,
                                      'Address',
                                      _addressController.text,
                                    ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          if (_isEditing)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _saveProfile,
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: Text(
                                    'Save Profile',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  )),
    );
  }

  Widget _buildProfileImage() {
    // Handle image display with better error handling
    if (_selectedImage != null) {
      return CircleAvatar(
        radius: 58,
        backgroundColor: Colors.grey[100],
        backgroundImage: FileImage(_selectedImage!),
      );
    } else if (_profileImageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 58,
        backgroundColor: Colors.grey[100],
        backgroundImage: NetworkImage(_profileImageUrl),
        onBackgroundImageError: (exception, stackTrace) {
          print('Error loading profile image: $exception');
        },
      );
    } else if (_currentUser?.photoURL != null) {
      return CircleAvatar(
        radius: 58,
        backgroundColor: Colors.grey[100],
        backgroundImage: NetworkImage(_currentUser!.photoURL!),
        onBackgroundImageError: (exception, stackTrace) {
          print('Error loading profile image: $exception');
        },
      );
    } else {
      return CircleAvatar(
        radius: 58,
        backgroundColor: Colors.grey[100],
        child: const Icon(
          Icons.admin_panel_settings,
          size: 48,
          color: Color(0xFFAEAEAE),
        ),
      );
    }
  }

  Widget _buildNotLoggedInView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.admin_panel_settings,
            size: 100,
            color: Color(0xFFE0E0E0),
          ),
          const SizedBox(height: 16),
          const Text(
            'Admin Access Required',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              // Navigate to admin login
            },
            child: const Text('Admin Login'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileField(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[500]),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: Text(
            value.isEmpty ? 'Not provided' : value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
