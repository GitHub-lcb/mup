import React, { createContext, useContext, useEffect, useState } from 'react';
import { User } from '../types';
import api, { getToken, setToken, clearToken } from '../lib/api';

interface AuthContextType {
  user: User | null;
  loading: boolean;
  signIn: (email: string, password: string) => Promise<void>;
  signUp: (email: string, password: string, nickname?: string) => Promise<void>;
  signOut: () => Promise<void>;
  refreshUser: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Check if user is logged in
    const token = getToken();
    if (token) {
      fetchUserProfile();
    } else {
      setLoading(false);
    }
  }, []);

  const fetchUserProfile = async () => {
    try {
      const response: any = await api.auth.getUser();
      setUser(response.user as User);
    } catch (error) {
      console.error('Error fetching user profile:', error);
      // Token might be invalid, clear it
      clearToken();
      setUser(null);
    } finally {
      setLoading(false);
    }
  };

  const signIn = async (email: string, password: string) => {
    const response: any = await api.auth.login({ email, password });
    setToken(response.token);
    setUser(response.user as User);
  };

  const signUp = async (email: string, password: string, nickname?: string) => {
    const response: any = await api.auth.register({ email, password, nickname });
    setToken(response.token);
    setUser(response.user as User);
  };

  const signOut = async () => {
    await api.auth.logout();
    clearToken();
    setUser(null);
  };

  const refreshUser = async () => {
    await fetchUserProfile();
  };

  return (
    <AuthContext.Provider value={{ user, loading, signIn, signUp, signOut, refreshUser }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}
