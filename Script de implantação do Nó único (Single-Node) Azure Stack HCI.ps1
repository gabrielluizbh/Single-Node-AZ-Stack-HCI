## Script de implantação do Nó único (Single-Node) Azure Stack HCI - Créditos Gabriel Luiz - www.gabrielluiz.com ##


# 1. Verifique se o Active Directory e o DNS estão instalados e acessíveis.

# 2. verifique se você tem acesso a credenciais de domínio e senha relevantes para adicionar um computador ao domínio.

# 3. Verifique se o DHCP está instalado e acessível (opcional, se necessário). Se não for DHCP, o endereço IP estático/Gateway padrão e o endereço IP DNS/FQDN são conhecido.

# 4. Instale o sistema operacional Azure Stack HCI em seu servidor, você pode fazer o download em https://azure.microsoft.com/products/azure-stack/hci/?WT.mc_id=WDIT-MVP-5003815

# 5. Configure o servidor Azure Stack HCI utilizando o Sconfig.

  # a. Se configuração estática - Configure endereços IP, gateway padrão e DNS para adaptadores de gerenciamento.
  # b. Ativar RDP (Acesso remoto).
  # c. Altere o nome do computador (se necessário).
  # d. Alterar fuso horário (se necessário).
  # e. Adicionar servidor ao domínio (escolha não reinicializar).
  # f. Adicionar o usuário do domínio ao grupo de administradores locais. Comando: Net localgroup administrators DOMAIN\USER /add
  # g. Instale os recursos necessários (usando Sconfig, saia para o PowerShell, opção 15). Comando: 
        
  Install-WindowsFeature -Name Hyper-V, Failover-Clustering, FS-DataDeduplication, Bitlocker, Data-Center-Bridging, RSAT-ADPowerShell, NetworkATC -IncludeAllSubFeature -IncludeManagementTools -Verbose
  
  # h. Instale atualizações cumulativas usando Sconfig, selecione a opção 6, depois a opção 1 e depois 3, selecione para baixar instalar todas as atualizações de qualidade ou recursos.
  # i. Renicie o servidor para aplicar as atualizações.

# 6. Faça login com o usuário do domínio que é o administrador local.

# 7. Você pode renomear NICs usando estes comandos de exemplo (opcional, prática recomendada).
 
  # a.
  Rename-NetAdapter -Name "Ethernet" -NewName "MGMT-A" 

  # b.
  Rename-NetAdapter -Name "Ethernet 2" -NewName "MGMT-B"

# 8. Crie e configure um vSwitch.
  
  # a.
  New-VMSwitch -name ExternalSwitch -NetAdapterName mgmt-a, mgmt-b -AllowManagementOS $true

  # b. Use Sconfig para configurar (opcional, se estiver usando DHCP, talvez não seja necessário fazer isso).Configure o endereço de rede, gateway padrão e DNS para vSwitch.

# 9. Configurar NetworkATC.
  
  # a.
  Add-NetIntent -Name Management_Compute -Management -Compute -ComputerName localhost -AdapterName MGMT-A,MGMT-B

  # b. Configurar VLAN de gerenciamento (opcional).
  SetNetIntent -Name Management_Compute -ManagementVLAN 10

  # c. Use Sconfig para configurar (se estiver usando DHCP, talvez não seja necessário fazer isso) (opcional). Configure o endereço de rede, gateway padrão e DNS para vSwitch.
  
# 10. Criar cluster.
  
  # a. (você pode pular -StaticAddress ""cluster IPAddress"" se estiver usando DHCP).
  New-Cluster -Name ClusterName -Node NodeName.domain.com -StaticAddress "cluster IPAddress" –NOSTORAGE

# 11. Ativar S2D.
  
  # a.
  Enable-ClusterS2D -verbose

# 12. Adicione o servidor ao gerenciamento de cluster do Windows Admin Center, adicione pelo DNS ou IP (mais rápido).

# 13. Registre o cluster em sua assinatura Azure (use Windows Admin Center ou PowerShell).

  # a. Powershell.
     # I. Baixe o módulo (se necessário).
      # 1.
       Install-Module -Name Az.StackHCI
     
     # II. Use o comdlet register para se registrar no Azure.
      #1. (-ResourceGroupName é opcional)
     Register-AzStackHCI -SubscriptionId "<subscription_ID>" -ComputerName Server1 -ResourceGroupName cluster1-rg

  # b. Windows Admin Center.
     # I. Passo 1 - Instruções: https://docs.microsoft.com/en-us/azure-stack/hci/manage/register-windows-admin-center?WT.mc_id=WDIT-MVP-5003815
     # II. Passo 2 - Instruções: https://docs.microsoft.com/en-us/azure-stack/hci/deploy/register-with-azure?WT.mc_id=WDIT-MVP-5003815

# 14. Agora você está pronto para o volume e cria máquinas virtuais.

  # a. Crie um volume pelo PowerShell (atualmente o Windows Admin Center tem um bug, a Microsoft está trabalhando para corrigir.)
     # I.
     New-Volume -FriendlyName "Volume1" -FileSystem CSVFS_ReFS -StoragePoolFriendlyName S2D* -Size 1TB -ProvisioningType Thin

# 15. Crie uma máquina virtual pelo Windows Admin Center armazenando no volume1.

     # I. Passo 1 - Instruções: https://docs.microsoft.com/pt-br/windows-server/manage/windows-admin-center/use/manage-virtual-machines?WT.mc_id=WDIT-MVP-5003815


<#

Referências:


https://techcommunity.microsoft.com/t5/azure-stack-blog/announcing-azure-stack-hci-support-for-single-node-clusters/ba-p/3408431?WT.mc_id=WDIT-MVP-5003815

https://docs.microsoft.com/pt-br/azure-stack/hci/concepts/single-server-clusters?WT.mc_id=WDIT-MVP-5003815

https://docs.microsoft.com/pt-br/azure-stack/hci/deploy/single-server?WT.mc_id=WDIT-MVP-5003815

https://docs.microsoft.com/en-us/azure-stack/hci/manage/register-windows-admin-center?WT.mc_id=WDIT-MVP-5003815

https://docs.microsoft.com/en-us/azure-stack/hci/deploy/register-with-azure?WT.mc_id=WDIT-MVP-5003815

https://docs.microsoft.com/pt-br/azure-stack/hci/manage/create-volumes?WT.mc_id=AZ-MVP-5003815#create-volumes-using-windows-powershell

https://docs.microsoft.com/pt-br/windows-server/manage/windows-admin-center/use/manage-virtual-machines?WT.mc_id=WDIT-MVP-5003815


#>
