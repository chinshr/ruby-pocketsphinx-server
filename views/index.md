# Real-time speech recognition server 



## This Page

This page describes the Cybernetics Institute [foneetika- Speech Technology Laboratory] (http://www.phon.ioc.ee) real-time speech recognition server and its usage. 

## Server

The server is designed for short (max. Approximately 20 seconds) with Estonian kõnelõikude detection. 

The server source code is available under the BSD license [here] (https://github.com/alumae/ruby pocketsphinx-to-server). 

The server itself is based on a number of free software components for which licenses should be taken into account when using the remote. 
Key technologies which are used at the server: 

* [CMU Sphinx] (http://cmusphinx.org) - the server uses for voice recognition decoder Pocketsphinx 
* [Wapiti] (http://wapiti.limsi.fr) - used for the reconstruction of compound words 
* [Sinatra] (http://www.sinatrarb.com) - used by the web server framework 
* [Grammatical Framework] (http://www.grammaticalframework.org) - is used for GF-based Detection

## Applications

Who can use the server with two Android-platform app created by:

* [Spoken] (http://code.google.com/p/recognizer-intent) 
* [Calculation] (https://github.com/Kaljurand/Arvutaja)

<a href="http://market.android.com/search?q=pub:Kaarel Kaljurand">
  <img src="http://www.android.com/images/brand/45_avail_market_logo1.png"
       alt="Available in Android Market" />
</a>

Both apps are free and open source.

## Using the Java server applications 

The server is easy to use through a special library, which is free and available with source code 
[here] (http://code.google.com/p/net-Speech API).

## The use of other server applications

The server is very easy to use "straight" without vaheteegita. Here we show you how 
servers use the Linux command line.

### Example 1: The raw audio format

Record microphone in one short sentence, using the <i>Raw</i> format, 16 KB, mono encoding (press Ctrl-C when you are finished): 

    arecord --format=S16_LE  --file-type raw  --channels 1 --rate 16000 > lause1.raw

Now, get a phrase identifying the server (using the program <code> Curl </code>, available repositoriumites all in Linux):

    curl -X POST --data-binary lause1.raw \
      -H "Content-Type: audio/x-raw-int; rate=16000" \
      http://bark.phon.ioc.ee/speech-api/v1/recognize?nbest=1

The server generates a response in JSON format: 

    {
      "status": 0,
      "hypotheses": [
        {
          "utterance": "see on esimene lause"
        }
      ],
      "id": "4d00ffd9b1a101940bb3ed88c6b6300d"
    }

### Example 2: ogg audio format 

The server knows the formats flac, ogg, mpeg, wav. Query the Content-Type field for that should be the case, according to the audio / x-flac, application / ogg, audio / mpeg or audio / x-wav.

Stored in the Ogg format sentence (for this package should be installed SOx):

    rec -r 16000 lause2.ogg
    
We will send to the server using the PUT request: 
    
    curl -T lause2.ogg -H "Content-Type: application/ogg"  "http://bark.phon.ioc.ee/speech-api/v1/recognize?nbest=1"

Response:

    {
      "status": 0,
      "hypotheses": [
        {
          "utterance": "see on teine lause"
        }
      ],
      "id": "dfd8ed3a028d1e70e4233f500e21c027"
    }


### Example 3: multiple tuvastushüpoteesi 

Parameter `nbest = 1`, said in the previous query to the server that we are interested in Only one result. By default, the server will give way to the most probable tuvastushüpoteesi, the order of the likelihood of the hypothesis:

    curl -X POST --data-binary @lause1.raw \
      -H "Content-Type: audio/x-raw-int; rate=16000" \
      http://bark.phon.ioc.ee/speech-api/v1/recognize


Response:

    {
      "status": 0,
      "hypotheses": [
        {
          "utterance": "see on esimene lause"
        },
        {
          "utterance": "see on esimene lause on"
        },
        {
          "utterance": "see on esimene lausa"
        },
        {
          "utterance": "see on mu esimene lause"
        },
        {
          "utterance": "see on esimene laose"
        }
      ],
      "id": "61c78c7271026153b83f39a514dc0c41"
    }

### Example 4: Using the grammar JSGF 

By default, the server uses a statistical language model that attempts to find the right 
tuvastushüpoteesi all kinds of Estonian-language statements. Sometimes it is However, a useful phrase to limit the potential for rule grammar. Server allows to define grammars in two formats: 

* [JSGF] (http://java.sun.com/products/java-media/speech/forDevelopers/JSGF/) and 
* [GF] (http://www.grammaticalframework.org/).

For example, the grammar below JSGF format accepted by, inter alia, such phrases: 

* Go Forward 

* Go back to two meters 

* move forward one meter 

* turn right 

Grammar:

    #JSGF V1.0;
      
    grammar robot;
       
    public <command> = <liigu> | <keera>;
    <liigu> = (liigu | mine ) [ ( üks meeter ) | ( (kaks | kolm | neli | viis ) meetrit ) ] (edasi | tagasi );
    <keera> = (keera | pööra) [ paremale | vasakule ];

Grammar, you must first load the web server somewhere, where it would be kättessadav all around (such as Dropbox <i>Public Folders </i>). In this case, the Grammar [here] (http://www.phon.ioc.ee/~tanela/tmp/robot.jsgf). 

Then, kõnetuvastusserverile say that he knocked down the grammar:
      
    curl "http://bark.phon.ioc.ee/speech-api/v1/fetch-lm?url=http://www.phon.ioc.ee/~tanela/tmp/robot.jsgf"

Then recording of the sentence (such as "move forward one meter", Ctrl-C when finished):

    rec -r 16000 liigu_1m_edasi.ogg

Grammar should be using to identify the query to add the parameter <code> lm = http: //www.phon.ioc.ee/~tanela/tmp/robot.jsgf </code>:

    curl -T liigu_1m_edasi.ogg \
      -H "Content-Type: application/ogg" \
      "http://bark.phon.ioc.ee/speech-api/v1/recognize?nbest=1&lm=http://www.phon.ioc.ee/~tanela/tmp/robot.jsgf"
    
Response:

    {
      "status": 0,
      "hypotheses": [
        {
          "utterance": "liigu \u00fcks meeter edasi"
        }
      ],
      "id": "c858c89badc3597ca8ec7f10985b71de"
    }

Note: JSGF grammars format should be ISO-8859-14 encoding. The server response is UTF-8 encoded as JSON standard provides. 

### Example 5: Using the GF grammar format (advanced) 

GF is grammatikaformalism which allows, inter alia, one of the abstract grammar implementats iooni create several different languages. For example, the abstract grammar can be designed to control the robot, with its Design and Implementation of the Estonian language defines how the robot to drive in the Estonian language, and the Design and Implementation of a second 
"machine language" defined by the robot's understandable syntax. 

Lots of Estonian implementatsiooniga GF grammars found [here](http://kaljurand.github.com/Grammars/).

As JSGF for the GF grammar must be loaded on the server, using the binary GF 
format (PGF). This case must also specify, 
grammatikaimplementatsiooni the server should use for voice recognition, using the parameter <code> lang </code>:

    curl "http://bark.phon.ioc.ee/speech-api/v1/fetch-lm?url=http://kaljurand.github.com/Grammars/grammars/pgf/Go.pgf&lang=Est"

We record again in the sentence (eg, "go to four meters ahead"): 

    rec R 16000 mine_4m_edasi.ogg 

Detected, the display server, what is the desirable outcome of the case (parameter <code> output-lang = App </code>): 

    curl -T mine_4m_edasi.ogg \ 
      -H "Content-Type: application / ogg '\ 
    "http://bark.phon.ioc.ee/speech-api/v1/recognize?nbest=1&lm=http://kaljurand.github.com/Grammars/grammars/pgf/Go.pgf&output-lang=App" 

Response: 

    {
      "status": 0, 
      "Hypotheses": [
      {
        "linearizations": [
        {
          "lang": "App" 
          "output", "4 m>" 
        } 
        ], 
        "utterance": "to four meters ahead" 
      } 
      ], 
      "id": "e2f3067d69ea22c75dc4b0073f23ff38" 
    } 

The reply is now each hypothesis at the <code> linearizations </code>, providing input to "linearisatsiooni" (ie translation), the output language. This grammar Output Linearisation is the language of "4 m>" what is the robot may be easier to parse than English command. 

When PGF file grammatikaimplementatsioone have more time to ask for the output in multiple languages: 

    curl -T mine_4m_edasi.ogg \ 
      -H "Content-Type: application/ogg" \ 
      "http://bark.phon.ioc.ee/speech-api/v1/recognize?nbest = 1&lm=http://kaljurand.github.com/Grammars/grammars/pgf/Go.pgf&output-lang=App,Eng,Est" 

Response: 

    {
      "status": 0, 
      "Hypotheses": [
      {
        "linearizations": [
        {
          "lang": "App" 
          "output", "4 m>" 
        }, 
        {
          "drop", "Eng", 
          "output", "Go forward four meters" 
        }, 
        {
          "drop", "Est", 
          "output", "to four meters ahead" 
        } 
        ], 
        "utterance": "to four meters ahead" 
      } 
      ], 
      "id": "d9abdbc2a7669752059ad544d3ba14f7" 
    } 

## Frequently Asked Questions 

#### Does the server save my transcriptions? 

Yes. Generally, these recordings do not listen to anyone, but may be random manually transcribe recordings to listen to and evaluate the quality of detection and improve. 

#### Recognition quality is very bad! 

Yes. For the best quality of the microphone is close to your mouth. 
Hopefully the quality will improve in the future, if we have already sent to the server 
Records used to improve the models (see previous question). 


#### Can I use the server for unlimited free? 

Not quite. Who can be done from a single IP per hour to 100 per day and up to 200 tuvastuspäringut. 
In the future, these limits are subject to change (it depends on the popularity of the service, and our server park 
development). 


#### In what sense is it free? 

Technology has developed a national program "The Estonian Language Technology 2011-2017", ie, as 
the taxpayer has already paid the price. The state program does not put us right 
commitment to such a server to manage unlimited, because the future may 
operating conditions change, the server software, however, will always remain free if 
there would be no other seniarvestamata circumstances. 

#### OK, but if I can then install a tuvastustarkava own server? 

Yes. The server software is available [here] (https://github.com/alumae/ruby-pocketsphinx-server) 
Estonian language and the statistical language model and an acoustic fusion of words rekonstrueerimismudeli 
please contact. Models are not really "free", mp these are certain 
restrictions on use (for example, they may not be disseminated).

#### Will iOS (Windows Phone 7, BlackBerry, Meego) to be operational? 

There is currently no plan. However, the server is available to all applications, so it 
an application can reimplement a third party. 

## Contacts 

Tanel Alumäe: [tanel.alumae@phon.ioc.ee] (tanel.alumae@phon.ioc.ee)