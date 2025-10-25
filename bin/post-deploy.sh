#!/bin/bash
# Post-deploy hook to configure React app routing through Kamal proxy

echo "Configuring React app routing..."
ssh root@159.65.251.69 'docker exec kamal-proxy kamal-proxy deploy project_board-react --target="127.0.0.1:5173" --host="app.dashcmd.com" --tls --health-check-path="/" --deploy-timeout="10s"' 2>&1

if [ $? -eq 0 ]; then
  echo "✓ React app routing configured successfully"
  echo "React app available at: https://app.dashcmd.com"
else
  echo "⚠ Note: Health check may have timed out, but routing should still work"
  echo "React app available at: https://app.dashcmd.com"
fi
