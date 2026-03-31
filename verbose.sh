[[ $EUID -ne 0 ]] && echo "Run as root." && exit 1
 
AUTH_LOG="/var/log/auth.log"
 
echo "=== FAILED LOGINS ==="
grep -i "failed\|invalid user" "$AUTH_LOG" 2>/dev/null \
  | awk '{print $1, $2, $3, $9, $11}' | tail -n 10 \
  || echo "None found."
 
echo ""
echo "=== SUCCESSFUL LOGINS ==="
grep -i "accepted" "$AUTH_LOG" 2>/dev/null \
  | awk '{print $1, $2, $3, $9, $11}' | tail -n 10 \
  || echo "None found."
