import 'dart:io';
import 'package:http/http.dart' as http;

class DropboxService {
  static const String _accessToken = 'sl.u.AGOqBt4FdNk4RTxtkXSIN6w-yiQEDr_QscOSKVOIFiwo7eYopWRHN2YQzm6bzAovDLq5ns_ird0jZQ_Ewo8EWnJegGCF-ctw8oIZ84GrlItSyQe6BHxssugFSbG0nqSS6y6AkPNY4HfwgsVXqBTaIBoimR_ADUbCy5LjANohpN7VdWQ9YMkov9lTxbtf6YdLr9dhm3KXQjhe8un-wit0MwITS-CNMjXmOVQAp2eVhe4NPODcPU3g1ubv6DRkjUsS45r07Vu4eKiAQtTcdkPkVGFkghfXLNInkieLSCkE5kvlkhMmxo6FHOHlTvx9ZHNmse7pqgf-3R_Fzo5VKlyKeZcEst0QcXG2lXaOB2_gEYOER-FUOfiT9v5EICCw6Z5lojEn0DrPBUcuWWELCJTTvQugAxeI-k0QGBblkb82ycOA33EnmVQoIB72yGer65mu5jDN9qhiVFmueRgc6MT84ei3qTxHY93lG4ulsHSAVvdNjl9iXHsOVKCWuFCLuH2fD1ieIdmKabPem0E3uEXeVrF03VI-iPOuvBXJJssDeO8m4goBMjx8N9pqbs0grjU4M2vPLuJds-Dd6IzPNyJcTQ62I5eSbLjs5ejBZDtUCClI4ESoBJri-nuQxuGuY5zc1E8R4_q1TDK9jRRIUWjbVZ2WwdwsZ0GXXnezb2nBIBPJEQYTgSCgoWBpoLvpm1yJjL0IFiBI4U8oXlwf_YezZ6s9DsjPRaIRaCy0NhGUdzTsU9BY4IUbilYfzjgT7DES90VXCuyEtnCYUxJvu6b9UScs1xbBWWtwnHyoH5e_ltzMzJz2Ai4vavXX5KD040vRkYa7QCtD2hye3MrVuhdutFChYqsFXd8J6Cl3q9DUFVdYMNaKKoW7YauCqPvLhPBAVRDooRp-rKD9C2OPvtJo_YYki9XYdaC8oX8qJE7kNb2lwU4hZSpMXzFHDPxFj03l0bG2uO997QJD3VO8Igq3NcfoHydPpTJRx_VExkt7TiEj_vtsA6Vp8tiPQLmcyJdw7CjyIOQSUIS_XUHnOGa6VoHu2MgpwK7yAjbb7nLl8wxOdLzh5_26coxFYw52Azb8TSZEGPsBDbZEz2_kjJBAhSpLNHgmpasOGC0WgNjzY4PAl_iCZUlfhXYBbTRMkMn8hGUqWZHFOsKhPg4vZVKRE9QQXDc3TB1hhVnR1QqyyiNupld96F5_5GbNtx2oAwPZRSsrSYhMS4qbx8-cshObMESyAas4MCVMO_iF9DGMdy2iK5hRpM-x00xX3OG0VcOMPLsTFvbykpztv5x7hKvbKBo2bVOlj6vRuICIhUPwVhUaFb6nAzXyQovWqIPo_NzbniI2UQGwd4_C02BZxTroB1Pji9PhsGQqqZrdQQH3IwrUdobmISunQVMW2RAcZ2UqncPEeeIB-D1HJRxgJ_tJ-iDk3xz636M7A4Cc_A5On7_BAA';

  static Future<bool> uploadFile({
    required File file,
    required String fileName,
  }) async {
    final url = Uri.parse('https://content.dropboxapi.com/2/files/upload');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Dropbox-API-Arg': '{"path":"/notemates/$fileName","mode":"add","autorename":true}',
        'Content-Type': 'application/octet-stream',
      },
      body: await file.readAsBytes(),
    );

    return response.statusCode == 200;
  }
}
