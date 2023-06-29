import json
import boto3
import os

network_firewall_policy_arn = os.environ['NETWORK_FIREWALL_POLICY_ARN']
rule_group_arn = os.environ['NETWORK_FIREWALL_RULE_GROUP_ARN']
client = boto3.client('network-firewall')

def lambda_handler(event, context):
    #Loops through every file uploaded
    for record in event['Records']:
        print(record["body"])
        jsonPayload=json.loads(record["body"])
        if jsonPayload["alertTypeName"] == "IPRateExceeded":
            block_ip(jsonPayload["remote_ip"])
        if jsonPayload["alertTypeName"] == "UnblockIP":
            unblock_ip(jsonPayload["remote_ip"])

    return {"statusCode":200, "body":"Successfully posted to SQS"}

def block_ip(ipaddress):
    print("blocking ip: " + ipaddress)
    responseDescribe = client.describe_rule_group(RuleGroupArn=rule_group_arn,Type='STATELESS')
    try:
        rulesSource = responseDescribe["RuleGroup"]["RulesSource"]
        print("rulesSource: " + str(rulesSource)) 
        statelessRulesAndCustomActions = rulesSource["StatelessRulesAndCustomActions"]
        print("statelessRulesAndCustomActions: " + str(statelessRulesAndCustomActions))
        statelessRules = statelessRulesAndCustomActions["StatelessRules"]
        print("statelessRules: " + str(statelessRules))
        alreadyBlocked = False
        for rule in statelessRules:
            print(rule["RuleDefinition"]["MatchAttributes"]["Sources"][0]["AddressDefinition"])
            if rule["RuleDefinition"]["MatchAttributes"]["Sources"][0]["AddressDefinition"] == ipaddress:
                print("ip already blocked: " + ipaddress)
                alreadyBlocked = True
                
        if alreadyBlocked == False:
            ruletoAdd = {"RuleDefinition": {"MatchAttributes": {"Sources": [{"AddressDefinition": ipaddress}]}, "Actions": ["aws:drop"]}, "Priority": 1}
            statelessRules.append(ruletoAdd)
            print(statelessRules)
            print("Sending following payload: ")
            print(responseDescribe["RuleGroup"])
            response = client.update_rule_group(UpdateToken=responseDescribe["UpdateToken"],
                                                RuleGroupArn=rule_group_arn,
                                                RuleGroup=responseDescribe["RuleGroup"],
                                                Type='STATELESS',
                                                DryRun=False)
            print(response)
    except:
        raise

    

def unblock_ip(ipaddress):
    print("unblocking ip: " + ipaddress)
    print("blocking ip: " + ipaddress)
    responseDescribe = client.describe_rule_group(RuleGroupArn=rule_group_arn,Type='STATELESS')
    try:
        rulesSource = responseDescribe["RuleGroup"]["RulesSource"]
        print("rulesSource: " + str(rulesSource)) 
        statelessRulesAndCustomActions = rulesSource["StatelessRulesAndCustomActions"]
        print("statelessRulesAndCustomActions: " + str(statelessRulesAndCustomActions))
        statelessRules = statelessRulesAndCustomActions["StatelessRules"]
        print("statelessRules: " + str(statelessRules))
        isInBlockList = False
        newStatelessArray = []
        for rule in statelessRules:
            print(rule["RuleDefinition"]["MatchAttributes"]["Sources"][0]["AddressDefinition"])
            if rule["RuleDefinition"]["MatchAttributes"]["Sources"][0]["AddressDefinition"] == ipaddress:
                print("ip blocked, so we just remove it from block: " + ipaddress)
                isInBlockList = True
            else:
                newStatelessArray.append(rule)
        
        if isInBlockList:
            statelessRulesAndCustomActions["StatelessRules"] = newStatelessArray
            print(responseDescribe["RuleGroup"])
    
            response = client.update_rule_group(UpdateToken=responseDescribe["UpdateToken"],
                                                RuleGroupArn=rule_group_arn,
                                                RuleGroup=responseDescribe["RuleGroup"],
                                                Type='STATELESS',
                                                DryRun=False)
            print(response)
    except:
        raise
