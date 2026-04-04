## Laboratório Ansible
Testando automações em servidores Ubuntu e Rocky Linux via Ansible.


## Execução

Executar o comando com a tag **--ask-valt-pass** para usar as credenciais da secrets group_vars/haproxy.yaml que possui a senha sudo do grupo [haproxy].

```bash
 ansible-playbook -i hosts provisioning.yaml --ask-vault-pass
```
