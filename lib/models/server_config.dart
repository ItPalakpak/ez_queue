import 'package:cloud_firestore/cloud_firestore.dart';

class ServerConfig {
  final String ip;
  final String? lanIp;
  final String? backendTunnel;
  final String? reverbTunnel;
  final String? frontendTunnel;
  final bool tunnelsActive;

  ServerConfig({
    required this.ip,
    this.lanIp,
    this.backendTunnel,
    this.reverbTunnel,
    this.frontendTunnel,
    this.tunnelsActive = false,
  });

  factory ServerConfig.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ServerConfig(
      ip: data['ip'] as String? ?? '',
      lanIp: data['lan_ip'] as String?,
      backendTunnel: data['backend_tunnel'] as String?,
      reverbTunnel: data['reverb_tunnel'] as String?,
      frontendTunnel: data['frontend_tunnel'] as String?,
      tunnelsActive: data['tunnels_active'] as bool? ?? false,
    );
  }
}
