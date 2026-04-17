import React, { useState, useEffect } from 'react';
import { View, StyleSheet, ImageBackground, Text, NativeModules, StatusBar, SafeAreaView } from 'react-native';
import Dock from './components/Dock';
import StartMenu from './components/StartMenu';

const { HellfireWindowManager } = NativeModules;

const App = () => {
  const [runningApps, setRunningApps] = useState([]);
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const [currentTime, setCurrentTime] = useState(new Date());

  useEffect(() => {
    const timer = setInterval(() => setCurrentTime(new Date()), 60000);
    return () => clearInterval(timer);
  }, []);

  const launchApp = (appName, url) => {
    HellfireWindowManager.createWindow(appName, url);
    if (!runningApps.includes(appName)) {
      setRunningApps(prev => [...prev, appName]);
    }
  };

  return (
    <View style={styles.container}>
      <StatusBar barStyle="light-content" translucent backgroundColor="transparent" />
      <ImageBackground 
        source={{ uri: 'https://images.unsplash.com/photo-1618005198919-d3d4b5a92ead' }} 
        style={styles.wallpaper}
      >
        <SafeAreaView style={styles.overlay}>
          <View style={styles.topBar}>
            <View style={styles.leftBar}>
              <Text style={styles.logo}>HELLFIRE</Text>
              <View style={styles.badge}><Text style={styles.badgeText}>PROXIMITY</Text></View>
            </View>
            <View style={styles.rightBar}>
              <Text style={styles.time}>{currentTime.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'})}</Text>
            </View>
          </View>

          <View style={styles.desktop} />

          <StartMenu 
            visible={isMenuOpen} 
            onClose={() => setIsMenuOpen(false)} 
            onLaunch={launchApp} 
          />
          
          <Dock 
            launchApp={launchApp} 
            runningApps={runningApps} 
            onStartPress={() => setIsMenuOpen(!isMenuOpen)} 
          />
        </SafeAreaView>
      </ImageBackground>
    </View>
  );
};

const styles = StyleSheet.create({
  container: { flex: 1 },
  wallpaper: { flex: 1, resizeMode: 'cover' },
  overlay: { flex: 1 },
  topBar: { height: 35, flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', paddingHorizontal: 20, backgroundColor: 'rgba(0,0,0,0.4)' },
  leftBar: { flexDirection: 'row', alignItems: 'center' },
  logo: { color: '#ff4500', fontWeight: '900', fontSize: 14, letterSpacing: 1 },
  badge: { backgroundColor: '#444', paddingHorizontal: 6, paddingVertical: 2, borderRadius: 4, marginLeft: 8 },
  badgeText: { color: 'white', fontSize: 8, fontWeight: 'bold' },
  time: { color: 'white', fontSize: 13, fontWeight: '600' },
  desktop: { flex: 1 },
});

export default App;
