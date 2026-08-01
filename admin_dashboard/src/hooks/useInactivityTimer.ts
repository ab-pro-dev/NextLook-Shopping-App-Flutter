import { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { logoutAdmin, isAuthenticatedAdmin } from '../services/api';

const INACTIVITY_TIMEOUT_MS = 30 * 60 * 1000; // 30 minutes
const THROTTLE_INTERVAL_MS = 5 * 1000; // 5 seconds throttle

export function useInactivityTimer() {
  const navigate = useNavigate();

  useEffect(() => {
    if (!isAuthenticatedAdmin()) return;

    let lastUpdate = 0;

    const recordActivity = () => {
      const now = Date.now();
      if (now - lastUpdate > THROTTLE_INTERVAL_MS) {
        lastUpdate = now;
        localStorage.setItem('lastActivityTime', now.toString());
      }
    };

    // Initialize activity timestamp if not set
    if (!localStorage.getItem('lastActivityTime')) {
      localStorage.setItem('lastActivityTime', Date.now().toString());
    }

    const events = ['mousemove', 'mousedown', 'keydown', 'scroll', 'touchstart', 'click'];
    events.forEach((event) => {
      window.addEventListener(event, recordActivity, { passive: true });
    });

    const checkInterval = setInterval(() => {
      if (!isAuthenticatedAdmin()) return;

      const lastActivityStr = localStorage.getItem('lastActivityTime');
      const lastActivity = lastActivityStr ? parseInt(lastActivityStr, 10) : Date.now();
      const idleTime = Date.now() - lastActivity;

      if (idleTime >= INACTIVITY_TIMEOUT_MS) {
        logoutAdmin('Session expired due to inactivity.');
        navigate('/login', { replace: true });
      }
    }, 10000); // Check every 10 seconds

    return () => {
      events.forEach((event) => {
        window.removeEventListener(event, recordActivity);
      });
      clearInterval(checkInterval);
    };
  }, [navigate]);
}
