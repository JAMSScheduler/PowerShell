ACTIVEMQ
==========

This module is utilized to send or receive messages between JAMS and an ActiveMQ server.

To utilize, ensure ActiveMQ.psm1 is saved into a folder named ActiveMQ in the root install directory of the JAMS Module, by default found here: C:\Program Files\MVPSI\Modules

Additionally, you can utilize the module as Windows Workflow Activities within JAMS, by storing the WFToolbox.ActiveMQ.config file within the JAMS Client folder, by default found here: C:\Program Files\MVPSI\JAMS\Client

cmdlets
==========
* Send-ActiveMQMessage
* Receive-ActiveMQMessage

Descriptions
==========
```
.Synopsis
   Send a message to an ActiveMQ queue.
.DESCRIPTION
   Sends a single message to an ActiveMQ queue. The message must be formatted
   as the reader of the queue expects. You should not include the "body=" tag.
.EXAMPLE
   Send-ActiveMQMessage -user joe -queue invoice -server sample.bigco.com -message $invoiceData -jamsserver localhost
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   None.
   
.Synopsis
   Receive a message from an ActiveMQ queue.
.DESCRIPTION
   Reads a single message from an ActiveMQ queue.
.EXAMPLE
   $newData = Receive-ActiveMQMessage -user joe -queue invoice -mqserver sample.bigco.com -jamsserver localhost
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   None.
```
