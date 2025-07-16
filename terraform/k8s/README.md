## AWS SSM 접속

### 인스턴스 조회

```shell
aws ec2 describe-instances
```

### sh 접속

```shell
aws ssm start-session --target {instanceId}
```

### bash 접속

```text
aws ssm start-session --target {instanceId} --document-name AWS-StartInteractiveCommand --parameters 'command=["sudo -u ec2-user bash"]'
```
