### Pre-requirements:
# Python installed.
# Rabbitmqadmin installed.
# Glow Azure VPN connection status active required.

# 1. Login to Azure:
az login --tenant "c5360f6f-0bb5-46b9-a278-75619bfd2434"

# 2. Get AKS credentials:
az aks get-credentials --resource-group DEV-GlowAKS --name glow-develop-aks --subscription "65de260e-4df4-4b57-9aa6-726e772d3246" --admin
kubectl config use-context glow-develop-aks

# 3. Set you RabbitMQ variables (set RabbitUser and RabbitPassword):
$RabbitUser = "agent"
$RabbitPassword = "agent"
$RabbitNamespace = "shared"
$RabbitVHost = "dev"

# 4. Get RabbitMQ private IP:
$RabbitIP = kubectl get endpoints rabbitmq -n $RabbitNamespace -o jsonpath='{..ip}'

# 1. Create RabbitMQ VHost (if required):
# kubectl exec -it rabbitmq-0 -n RabbitNamespace -- rabbitmqctl add_vhost $RabbitVHost

# 2. Set permissions for RabbitMQ user (if required):
# kubectl exec -it rabbitmq-0 -n $RabbitNamespace -- rabbitmqctl set_permissions -p $RabbitVHost $RabbitUser ".*" ".*" ".*"

# 3. Declare RabbitMQ objects:
# for emailsender:
python rabbitmqadmin -H $RabbitIP declare exchange --vhost=$RabbitVHost name=SendTemplatedEmail type=direct -u $RabbitUser -p $RabbitPassword
python rabbitmqadmin -H $RabbitIP declare exchange --vhost=$RabbitVHost name=SendEmail type=direct -u $RabbitUser -p $RabbitPassword
python rabbitmqadmin -H $RabbitIP declare queue --vhost=$RabbitVHost name=SendTemplatedEmail  durable=true -u $RabbitUser -p $RabbitPassword
python rabbitmqadmin -H $RabbitIP declare queue --vhost=$RabbitVHost name=SendEmail durable=true -u $RabbitUser -p $RabbitPassword
python rabbitmqadmin -H $RabbitIP --vhost=$RabbitVHost declare binding source=SendTemplatedEmail destination_type=queue destination=SendTemplatedEmail --u $RabbitUser -p $RabbitPassword
python rabbitmqadmin -H $RabbitIP --vhost=$RabbitVHost declare binding source=SendEmail destination_type=queue destination=SendEmail --u $RabbitUser -p $RabbitPassword
# for cp:
python rabbitmqadmin -H $RabbitIP declare queue --vhost=$RabbitVHost name=SMSSender.Send  durable=true -u $RabbitUser -p $RabbitPassword
python rabbitmqadmin -H $RabbitIP declare queue --vhost=$RabbitVHost name=NotificationSender.Send  durable=true -u $RabbitUser -p $RabbitPassword
python rabbitmqadmin -H $RabbitIP declare queue --vhost=$RabbitVHost name=CustomerCreated  durable=true -u $RabbitUser -p $RabbitPassword

# 4. (Optional). To check if RabbitMQ objects have been created:
python rabbitmqadmin -H $RabbitIP -V $RabbitVHost -u $RabbitUser -p $RabbitPassword list exchanges
python rabbitmqadmin -H $RabbitIP -V $RabbitVHost -u $RabbitUser -p $RabbitPassword list queues
python rabbitmqadmin -H $RabbitIP -V $RabbitVHost -u $RabbitUser -p $RabbitPassword list bindings