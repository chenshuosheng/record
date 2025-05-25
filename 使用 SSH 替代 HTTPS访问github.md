## ✅ 目标：
要查看本机是否已经存在 SSH 密钥对（公钥和私钥），如果不存在，就需要生成一个新的。



---

## 🧰 步骤一：查看 `.ssh` 文件夹是否存在

在 PowerShell 中输入：

```powershell
Get-ChildItem $env:USERPROFILE\.ssh
```

如果输出类似下面的内容，说明已经有密钥了：

```
Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a----        2025/5/25   3:14            608  id_rsa
-a----        2025/5/25   3:14            221  id_rsa.pub
```

如果没有看到任何文件，或者提示“找不到路径”，说明你还没有生成过 SSH 密钥。



---

## 🔐 步骤二：生成新的 SSH 密钥

如果没有 SSH 密钥，请运行以下命令来生成一个：

### 使用 ED25519（推荐）：
```powershell
ssh-keygen -t ed25519 -C "your_email@example.com"
```

### 如果不支持 ED25519，可以用 RSA：
```powershell
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

然后按回车选择默认保存路径（通常为 `C:\Users\Administrator\.ssh\id_ed25519` 或 `id_rsa`），你可以设置密码也可以直接回车跳过。



---

## 📄 步骤三：查看你的公钥内容

生成完成后，查看公钥内容（用于添加到 GitHub）：

### 如果用的是 ED25519：
```powershell
Get-Content $env:USERPROFILE\.ssh\id_ed25519.pub
```

### 如果用的是 RSA：
```powershell
Get-Content $env:USERPROFILE\.ssh\id_rsa.pub
```

会看到类似这样的输出：

```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX your_email@example.com
```

复制这段内容，粘贴到 GitHub 的 [SSH Keys 设置页面](https://github.com/settings/keys) 中。



---

## 🧪 步骤四：测试 SSH 是否配置成功

```powershell
ssh -T git@github.com
```

如果一切正常，你会看到如下信息：

```
Hi your_username! You've successfully authenticated, but GitHub does not provide shell access.
```



---

## 🔄 步骤五：确保 Git 使用的是 SSH 地址

最后确认你的远程仓库地址是否是 SSH 格式：

```powershell
git remote -v
```

如果不是这个格式（比如还是 HTTPS）：

```text
git@github.com:chenshuosheng/record.git
```

请更新为 SSH 地址：

```powershell
git remote set-url origin git@github.com:chenshuosheng/record.git
```

---

## ✅ 总结

| 操作                   | 命令                                                         |
| ---------------------- | ------------------------------------------------------------ |
| 查看 `.ssh` 文件夹内容 | `Get-ChildItem $env:USERPROFILE\.ssh`                        |
| 生成新密钥             | `ssh-keygen -t ed25519 -C "your_email@example.com"`          |
| 查看公钥内容           | `Get-Content $env:USERPROFILE\.ssh\id_ed25519.pub`           |
| 测试 GitHub SSH 连接   | `ssh -T git@github.com`                                      |
| 设置 Git 使用 SSH 地址 | `git remote set-url origin git@github.com:chenshuosheng/record.git` |

---

现在把公钥添加到了 GitHub，并且远程仓库 URL 是 SSH 地址，再次尝试 `git push` 就应该可以成功了！
