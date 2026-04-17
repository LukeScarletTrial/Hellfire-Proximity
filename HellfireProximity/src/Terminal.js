import React, { useState } from 'react';
import { View, Text, TextInput, ScrollView, StyleSheet } from 'react-native';

const Terminal = () => {
  const [history, setHistory] = useState(['Hellfire OS [Version 1.0.0]', 'Type "help" for commands.']);
  const [input, setInput] = useState('');

  const handleCommand = () => {
    let response = '';
    const cmd = input.toLowerCase().trim();

    if (cmd === 'help') response = 'Available: help, jit-check, clear, ls';
    else if (cmd === 'jit-check') response = 'JIT Status: ACTIVE (High Performance)';
    else if (cmd === 'ls') response = 'valve/  debian.img  config.cfg';
    else if (cmd === 'clear') { setHistory([]); setInput(''); return; }
    else response = `Command not found: ${cmd}`;

    setHistory([...history, `> ${input}`, response]);
    setInput('');
  };

  return (
    <View style={styles.container}>
      <ScrollView contentContainerStyle={styles.scroll}>
        {history.map((line, i) => (
          <Text key={i} style={styles.text}>{line}</Text>
        ))}
      </ScrollView>
      <View style={styles.inputRow}>
        <Text style={styles.prompt}># </Text>
        <TextInput 
          style={styles.input}
          value={input}
          onChangeText={setInput}
          onSubmitEditing={handleCommand}
          autoCapitalize="none"
          autoCorrect={false}
        />
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#000', padding: 10 },
  scroll: { paddingBottom: 20 },
  text: { color: '#0f0', fontFamily: 'Courier', fontSize: 14 },
  inputRow: { flexDirection: 'row', alignItems: 'center' },
  prompt: { color: '#0f0', fontFamily: 'Courier' },
  input: { color: '#fff', flex: 1, fontFamily: 'Courier' }
});

export default Terminal;
