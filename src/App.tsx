import { Routes, Route } from 'react-router-dom';
import Layout from './components/Layout';
import ProtectedRoute from './components/ProtectedRoute';
import HomePage from './pages/HomePage';
import LoginPage from './pages/auth/LoginPage';
import RegisterPage from './pages/auth/RegisterPage';
import QuestionListPage from './pages/questions/QuestionListPage';
import QuestionDetailPage from './pages/questions/QuestionDetailPage';
import ProfilePage from './pages/user/ProfilePage';
import ProgressPage from './pages/user/ProgressPage';
import FavoritesPage from './pages/user/FavoritesPage';
import MistakesPage from './pages/user/MistakesPage';
import DailyChallengePage from './pages/DailyChallengePage';
import LeaderboardPage from './pages/LeaderboardPage';
import PricingPage from './pages/PricingPage';
import AdminLayout from './pages/admin/AdminLayout';
import AdminDashboard from './pages/admin/AdminDashboard';
import AdminQuestionList from './pages/admin/AdminQuestionList';
import AdminQuestionEditor from './pages/admin/AdminQuestionEditor';
import { AuthProvider } from './context/AuthContext';

function App() {
  return (
    <AuthProvider>
      <Routes>
        <Route path="/" element={<Layout />}>
          <Route index element={<HomePage />} />
          <Route path="daily" element={<DailyChallengePage />} />
          <Route path="leaderboard" element={<LeaderboardPage />} />
          <Route path="pricing" element={<PricingPage />} />
          <Route path="auth/login" element={<LoginPage />} />
          <Route path="auth/register" element={<RegisterPage />} />
          <Route path="questions" element={<QuestionListPage />} />
          <Route path="questions/:id" element={<QuestionDetailPage />} />
          
          {/* User Protected Routes */}
          <Route element={<ProtectedRoute />}>
            <Route path="profile" element={<ProfilePage />} />
            <Route path="progress" element={<ProgressPage />} />
            <Route path="mistakes" element={<MistakesPage />} />
            <Route path="favorites" element={<FavoritesPage />} />
          </Route>
        </Route>

        {/* Admin Routes */}
        <Route element={<ProtectedRoute requireAdmin={true} />}>
          <Route path="/admin" element={<AdminLayout />}>
            <Route index element={<AdminDashboard />} />
            <Route path="questions" element={<AdminQuestionList />} />
            <Route path="questions/new" element={<AdminQuestionEditor />} />
            <Route path="questions/:id" element={<AdminQuestionEditor />} />
          </Route>
        </Route>
      </Routes>
    </AuthProvider>
  );
}

export default App;
