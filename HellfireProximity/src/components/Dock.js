import React from 'react';
import { View, StyleSheet, TouchableOpacity, Text } from 'react-native';

const Dock = ({ launchApp, runningApps }) => {
  const apps = [
    { name: 'Browser', color: '#2ecc71', url: 'https://www.google.com' },
    { name: 'Terminal', color: '#34495e', url: 'https://web-shell.com' }, // Placeholder for your Linux shell
    { name: 'Games', color: '#e67e22', url: 'https://classicreload.com' }, // Example game site
  ];

  return (
    <View style={styles.dockContainer}>
      <View style={styles.dock}>
        {apps.map((app) => (
          <View key={app.name} style={styles.iconWrapper}>
            <TouchableOpacity 
              style={[styles.icon, { backgroundColor: app.color }]}
              onPress={() => launchApp(app.name, app.url)}
            >
              <Text style={styles.iconText}>{app.name[0]}</Text>
            </TouchableOpacity>
            {/* Running Indicator Dot */}
            {runningApps.includes(app.name) && <View style={styles.indicator} />}
          </View>
        ))}
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  dockContainer: { position: 'absolute', bottom: 30, width: '100%', alignItems: 'center' },
  dock: { 
    flexDirection: 'row', 
    backgroundColor: 'rgba(255, 255, 255, 0.15)', 
    padding: 12, 
    borderRadius: 24,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.2)'
  },
  iconWrapper: { alignItems: 'center' },
  icon: { 
    width: 55, 
    height: 55, 
    borderRadius: 14, 
    marginHorizontal: 10, 
    justifyContent: 'center', 
    alignItems: 'center',
    shadowColor: '#000',
    shadowOpacity: 0.3,
    shadowRadius: 5,
  },
  iconText: { color: 'white', fontWeight: 'bold', fontSize: 18 },
  indicator: { 
    width: 4, 
    height: 4, 
    backgroundColor: 'white', 
    borderRadius: 2, 
    marginTop: 4 
  }
});

export default Dock;
