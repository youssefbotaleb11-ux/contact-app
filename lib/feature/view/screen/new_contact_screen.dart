import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NewContactScreen extends StatefulWidget {
  const NewContactScreen({super.key});

  @override
  State<NewContactScreen> createState() => _NewContactScreenState();
}

class _NewContactScreenState extends State<NewContactScreen> {
  // مفتاح الفورمة للـ Validation
  final _formKey = GlobalKey<FormState>();
  
  // الـ Controllers للتحكم في النص المدخل
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // متغير للتحكم في حالة التحميل أثناء الحفظ
  bool _isLoading = false;

  // دالة إضافة الكونتاكت إلى فايرستور
  Future<void> _addContact() async {
    // التحقق من صحة المدخلات أولاً
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // إرسال البيانات إلى مجموعة 'contacts' (بنفس اسم الهوم سكرين)
        await FirebaseFirestore.instance.collection('contacts').add({
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });

        // لو العملية نجحت، اظهر رسالة تأكيد وارجع بـ true عشان الهوم تحدث البيانات
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إضافة الكونتاكت بنجاح يا بطل! 🔥'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); 
        }
      } catch (e) {
        // في حال حدوث خطأ في الاتصال أو الحفظ
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('حدث خطأ أثناء الحفظ: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        // إيقاف الـ Loading في كلتا الحالتين
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Contact'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // حقل إدخال الاسم
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter contact name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'من فضلك أدخل الاسم يا بشمهندس';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // حقل إدخال رقم الهاتف
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter phone number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'من فضلك أدخل رقم الهاتف';
                  }
                  if (value.length < 6) {
                    return 'رقم الهاتف قصير جداً';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              // زر الإضافة مع حالة التحميل (Loading State)
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addContact,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          'Add New Contact',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}