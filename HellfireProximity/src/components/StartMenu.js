import React, { useState } from 'react';
import { View, Text, StyleSheet, TextInput, TouchableOpacity, FlatList, NativeModules } from 'react-native';

const { HFFilePicker, HellfireWindowManager } = NativeModules;

const StartMenu = ({ visible, onClose, onLaunch }) => {
  const [search, setSearch] = useState('');
  
  const handleImport = () => {
    HFFilePicker.pickLinuxFile((filePath) => {
        if (filePath) HellfireWindowManager.createWindow("Imported App", filePath);
    });
  };

  const apps = [
    { id: '1', name: 'Web Linux', icon: '🐧', url: 'https://copy.sh/v86/', color: '#333' },
    { id: '2', name: 'Browser', icon: '🌐', url: 'https://www.google.com', color: '#4285F4' },
  ];

  if (!visible) return null;

  return (
    <View style={styles.container}>
      <TouchableOpacity style={styles.backdrop} onPress={onClose} />
      <View style={styles.menu}>
        <TextInput 
          style={styles.searchBar} 
          placeholder="Search..." 
          placeholderTextColor="#888" 
          onChangeText={setSearch} 
        />
        
        <FlatList 
          data={apps.filter(a => a.name.toLowerCase().includes(search.toLowerCase()))}
          numColumns={3}
          renderItem={({ item }) => (
            <TouchableOpacity style={styles.appItem} onPress={() => { onLaunch(item.name, item.url); onClose(); }}>
              <View style={[styles.appIcon, { backgroundColor: item.color }]}><Text style={{fontSize: 30}}>{item.icon}</Text></View>
              <Text style={styles.appName}>{item.name}</Text>
            </TouchableOpacity>
          )}
        />

        <TouchableOpacity style={styles.importBtn} onPress={handleImport}>
          <Text style={styles.importText}>+ Import Linux App (.html/.js)</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: { position: 'absolute', inset: 0, zIndex: 999 },
  backdrop: { flex: 1 },
  menu: { position: 'absolute', bottom: 100, left: 20, width: 420, height: 500, backgroundColor: 'rgba(20,20,20,0.98)', borderRadius: 24, padding: 20, borderWidth: 1, borderColor: '#333' },
  searchBar: { backgroundColor: '#222', color: 'white', padding: 12, borderRadius: 12, marginBottom: 20 },
  appItem: { flex: 1, alignItems: 'center', marginBottom: 20 },
  appIcon: { width: 64, height: 64, borderRadius: 16, justifyContent: 'center', alignItems: 'center', marginBottom: 8 },
  appName: { color: 'white', fontSize: 11 },
  importBtn: { marginTop: 'auto', padding: 15, backgroundColor: '#ff4500', borderRadius: 12, alignItems: 'center' },
  importText: { color: 'white', fontWeight: 'bold' }
});

export default StartMenu;
