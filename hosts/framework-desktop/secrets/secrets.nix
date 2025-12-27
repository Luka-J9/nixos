let
  backup = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKbkTGWuht+9dqhwlL73tt8ShEn7u08549RtzCf21z6E";
  systems = [ backup ];

  user1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN5EDTRcNskZO6csiExGHzjWsQRkiP9H7Teb00zqFRCJ";
  users = [ user1 ];
in
{
  "secret1.age".publicKeys = users ++ [ backup ];
  "hashed-profile-password.age".publicKeys = users ++ [ backup ];
}
