# icinga2-msteams
A Icinga2 plugin to send notifications to MS teams

## prerequisites

These perl modules need to be installed.

 - HTTP::Request
 - LWP::UserAgent
 - JSON

## ToDo's
  - Write complete howto
  - Update Script --help command
  - Cleanup Director basket json, as it's a clone from the default mail notification command (unnessesary parameters and wrong naming)

## usage

`--webhook` is required option. 
`--ICINGAWEB2URL` to add a link in the notification.


## installation

1. place the script in /etc/icinga2/scripts/
2. `chmod +x /etc/icinga2/scripts/teams-*-notification.pl`
3. configure commands or import Director-Basket_TeamsNotifications.json into Icings-director
4. Add the complete Webhook URL (including https://) for Teams Channel as Pager into your contact.


# Reference

https://docs.microsoft.com/en-us/outlook/actionable-messages/message-card-reference?ranMID=24542&ranEAID=je6NUbpObpQ&ranSiteID=je6NUbpObpQ-M2yBpYvoiCsKiucg39ve7Q
