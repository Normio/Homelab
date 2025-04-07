for kv in \
  "PermitRootLogin no" \
  "PubkeyAuthentication yes" \
  "PasswordAuthentication no" \
  "KbdInteractiveAuthentication no" \
  "ChallengeResponseAuthentication no" \
  "MaxAuthTries 2" \
  "LoginGraceTime 20s" \
  "AllowTcpForwarding no" \
  "X11Forwarding no" \
  "AllowAgentForwarding no" \
  "UsePAM no" \
  "AuthenticationMethods publickey" \
  "AuthorizedKeysFile .ssh/authorized_keys"
do
  key=$(echo "$kv" | cut -d' ' -f1)
  val=$(echo "$kv" | cut -d' ' -f2-)
  
  # Match ONLY if line starts with key or #key (no whitespace before or between)
  grep -qE "^#?${key}\b" /etc/ssh/sshd_config \
    && sudo sed -i "s|^#\?${key}\b.*|${key} ${val}|" /etc/ssh/sshd_config \
    || echo "${key} ${val}" | sudo tee -a /etc/ssh/sshd_config >/dev/null
done

# Ensure AllowUsers wombat is present (same logic applies here)
grep -qE "^AllowUsers\b.*\bwombat\b" /etc/ssh/sshd_config \
  || echo "AllowUsers wombat" | sudo tee -a /etc/ssh/sshd_config >/dev/null

# Enable SSH service
sudo systemctl enable ssh

# Restart SSH service
sudo systemctl restart ssh