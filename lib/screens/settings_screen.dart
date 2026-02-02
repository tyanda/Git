import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isWifiOnly = false;
  bool _isAutoReconnect = true;
  String _selectedQuality = 'high';
  String _selectedNetwork = 'auto';

  final List<Map<String, String>> _networkOptions = [
    {'value': 'auto', 'label': 'Автоматически'},
    {'value': '2g', 'label': 'Только 2G'},
    {'value': '3g', 'label': 'Только 3G'},
    {'value': '4g', 'label': 'Только 4G'},
  ];

  final List<Map<String, String>> _qualityOptions = [
    {'value': 'high', 'label': 'Высокое (320 kbps)'},
    {'value': 'medium', 'label': 'Среднее (128 kbps)'},
    {'value': 'low', 'label': 'Низкое (64 kbps)'},
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color secondaryTextColor = isDark ? Colors.white70 : Colors.blueGrey.shade400;
    
    // Получаем размеры экрана
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    
    // Определяем, является ли устройство планшетом
    final bool isTablet = screenWidth > 600;
    
    // Адаптируем размеры элементов
    final double padding = isTablet ? 30.0 : 20.0;
    final double sectionSpacing = isTablet ? 40.0 : 30.0;
    final double itemSpacing = isTablet ? 20.0 : 10.0;
    final double iconSize = isTablet ? 30.0 : 24.0;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Настройки радио",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: isTablet ? 22.0 : 20.0,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor, size: isTablet ? 30.0 : 24.0),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                : [const Color(0xFFF8FAFC), const Color(0xFFE0F2FE)],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.all(padding),
          children: [
            // Настройки подключения
            Row(
              children: [
                Icon(Icons.wifi, size: iconSize, color: Colors.blueAccent),
                SizedBox(width: isTablet ? 15 : 10),
                _buildSectionTitle("Подключение", isDark, isTablet),
              ],
            ),
            SizedBox(height: itemSpacing / 2),
            _buildSwitchListTile(
              "Только по Wi-Fi",
              "Воспроизводить только при подключении к Wi-Fi",
              _isWifiOnly,
              (value) => setState(() => _isWifiOnly = value),
              isDark,
              secondaryTextColor,
              isTablet,
            ),
            _buildSwitchListTile(
              "Автоподключение",
              "Автоматически подключаться при запуске",
              _isAutoReconnect,
              (value) => setState(() => _isAutoReconnect = value),
              isDark,
              secondaryTextColor,
              isTablet,
            ),
            SizedBox(height: itemSpacing),
            _buildDropdownSetting(
              "Тип сети",
              _selectedNetwork,
              _networkOptions,
              (value) => setState(() => _selectedNetwork = value!),
              isDark,
              isTablet,
            ),
            SizedBox(height: sectionSpacing),
            
            // Настройки качества
            Row(
              children: [
                Icon(Icons.audiotrack, size: iconSize, color: Colors.orange),
                SizedBox(width: isTablet ? 15 : 10),
                _buildSectionTitle("Качество звука", isDark, isTablet),
              ],
            ),
            SizedBox(height: itemSpacing / 2),
            _buildDropdownSetting(
              "Качество потока",
              _selectedQuality,
              _qualityOptions,
              (value) => setState(() => _selectedQuality = value!),
              isDark,
              isTablet,
            ),
            SizedBox(height: sectionSpacing),
            
            // Информация о подключении
            Row(
              children: [
                Icon(Icons.info, size: iconSize, color: Colors.green),
                SizedBox(width: isTablet ? 15 : 10),
                _buildSectionTitle("Информация о подключении", isDark, isTablet),
              ],
            ),
            SizedBox(height: itemSpacing / 2),
            _buildInfoCard("Статус", "Подключено к 102.4 FM", isDark, secondaryTextColor, isTablet),
            _buildInfoCard("Тип подключения", "Wi-Fi (5.0 ГГц)", isDark, secondaryTextColor, isTablet),
            _buildInfoCard("Качество сигнала", "Отличное", isDark, secondaryTextColor, isTablet),
            _buildInfoCard("Битрейт", "320 kbps", isDark, secondaryTextColor, isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark, [bool isTablet = false]) {
    return Text(
      title,
      style: TextStyle(
        fontSize: isTablet ? 24.0 : 20.0,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : const Color(0xFF1E293B),
      ),
    );
  }

  Widget _buildSwitchListTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    bool isDark,
    Color secondaryTextColor,
    bool isTablet,
  ) {
    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF1E293B),
          fontWeight: FontWeight.w600,
          fontSize: isTablet ? 18.0 : 16.0,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: secondaryTextColor,
          fontSize: isTablet ? 16.0 : 14.0,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeThumbColor: Colors.blueAccent,
      inactiveThumbColor: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
      inactiveTrackColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
      contentPadding: EdgeInsets.symmetric(vertical: isTablet ? 12.0 : 8.0),
    );
  }

  Widget _buildDropdownSetting(
    String title,
    String value,
    List<Map<String, String>> options,
    Function(String?) onChanged,
    bool isDark,
    bool isTablet,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isTablet ? 18.0 : 16.0,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        SizedBox(height: isTablet ? 12.0 : 8.0),
        Container(
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 15, vertical: isTablet ? 8 : 5),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade800 : Colors.white,
            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
            border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: isDark ? Colors.white70 : Colors.blueGrey.shade400, size: isTablet ? 30 : 24),
              items: options.map((option) {
                return DropdownMenuItem(
                  value: option['value'],
                  child: Text(
                    option['label']!,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                      fontSize: isTablet ? 18.0 : 16.0,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
              style: TextStyle(fontSize: isTablet ? 18.0 : 16.0),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value, bool isDark, Color secondaryTextColor, bool isTablet) {
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
      padding: EdgeInsets.all(isTablet ? 20 : 15),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(isTablet ? 20 : 15),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.2)
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: secondaryTextColor,
              fontSize: isTablet ? 18.0 : 16.0,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              fontSize: isTablet ? 18.0 : 16.0,
            ),
          ),
        ],
      ),
    );
  }
}