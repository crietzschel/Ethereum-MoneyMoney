-- Inofficial Ethereum with Erc20-Tokens Extension for MoneyMoney
-- Fetches Ether quantity for address via etherscan API
-- Fetches Ether price in EUR via cryptocompare API
-- Returns cryptoassets as securities
--
-- Username: Ethereum with Erc20-Tokens Adresses comma seperated
-- Password: Etherscan API-Key

-- MIT License

-- Copyright (c) 2018 crietzschel

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.


WebBanking{
  version = 0.2,
  description = "Include your ETH & Tokens as cryptoportfolio in MoneyMoney by providing a Etheradresses (username, comma seperated) and etherscan-API-Key (Password)",
  services= { "Ethereum with Erc20-Tokens" }
}

local ethAddresses
local etherscanApiKey
local connection = Connection()
local mmcurrency = "EUR" -- fixme: make dynamik if MM enables input field


local symbolContractaddress = {
  TRX = "0xf230b790e05390fc8295f4d3f60332c93bed42e2", -- Tronix
  ICX = "0xb5a5f22694352c15b00323844ad545abb2b11028", -- ICON
  PPT = "0xd4fa1460f537bb9085d22c7bccb5dd450ef28e3a", -- Populous Platform
  OMG = "0xd26114cd6ee289accf82350c8d8487fedb8a0c07", -- OMGToken
  SNT = "0x744d70fdbe2ba4cf95131626614a1763df805b9e", -- Status Network
  VERI = "0x8f3470a7388c05ee4e7af3d01d8c722b0ff52374", -- Veritaseum
  REP = "0xe94327d07fc17907b4db788e5adf2ed424addff6", -- Reputation
  ZRX = "0xe41d2489571d322189246dafa5ebde1f4699f498", -- 0x Protocol Token
  DGD = "0xe0b7927c4af23765cb51314a0e0521a9645f0e2a", -- Digix DAO
  KNC = "0xdd974d5c2e2928dea5f71b9825b8b646686bd200", -- Kyber Network Crystal
  BAT = "0x0d8775f648430679a709e98d2b0cb6250d2887ef", -- Basic Attention Token
  PLR = "0xe3818504c1b32bf1557b16c238b2e01fd3149c17", -- PILLAR
  LRC = "0xef68e7c694f40c8202821edf525de3782458639f", -- loopring
  DCN = "0x08d32b0da63e2c3bcf8019c9c5d849d7a9d791e6", -- Dentacoin
  DENT = "0x3597bfd533a99c9aa083587b074434e61eb0a258", -- DENT
  GNT = "0xa74476443119a942de498590fe1f2454d7d4ac0d", -- Golem Network Token
  CND = "0xd4c435f5b09f855c3317c8524cb1f586e42795fa", -- Cindicator Token
  KIN = "0x818fc6c2ec5986bc6e2cbf00939d90556ab12ce5", -- Kin
  BNT = "0x1f573d6fb3f13d689ff844b4ce37794d79a7ff1c", -- Bancor Network Token
  PAY = "0xb97048628db6b661d4c2aa833e95dbe1a905b280", -- TenX Pay Token
  GNO = "0x6810e776880c02933d47db1b9fc05908e5386b96", -- Gnosis Token
  ICN = "0x888666ca69e0f178ded6d75b5726cee99a87d698", -- ICONOMI
  ANT = "0x960b236a07cf122663c4303350609a66a7b288c0", -- Aragon Network Token
  POE = "0x0e0989b1f9b8a38983c2ba8053269ca62ec9b195", -- Po.et
  CVC = "0x41e5560054824ea6b0732e656e3ad64e20e94e45", -- Civic
  SVD = "0xbdEB4b83251Fb146687fa19D1C660F99411eefe3", -- Savedroid
  QSP = "0x99ea4db9ee77acd40b119bd1dc4e33e1c070b80d", -- Quantstamp Token
  OST = "0x2C4e8f2D746113d0696cE89B35F0d8bF88E0AEcA", -- SimpleToken
  SALT = "0x4156d3342d5c385a87d264f90653733592000581", -- Salt
  ELF = "0xbf2179859fc6d5bee9bf9158632dc51678a4100e", -- ELF Token
  FUN = "0xbbb1bd2d741f05e144e6c4517676a15554fd4b8d", -- FunFair
  IOST = "0xfa1a856cfa3409cfa145fa4e20eb270df3eb21ab", -- IOSToken
  STORJ = "0xb64ef51c888972c908cfacf59b47c1afbc0ab8ac" -- StorjToken

  -- more to add ...
  -- use something like this ugly wget
  -- wget -O - "https://api.ethplorer.io/getTop?apiKey=freekey&criteria=cap" | tr '{' '\n' | cut -d'"' -f4,8,14 | tr '"' ';'  |  awk -v FS=';' '{ print "   "$3" = \""$1"≥\", -- "$2 }' | tr -d '≥' | grep -v "marketCapUsd"
  -- or look around in web
}


function SupportsBank (protocol, bankCode)
  return protocol == ProtocolWebBanking and bankCode == "Ethereum with Erc20-Tokens"
end

function InitializeSession (protocol, bankCode, username, username2, password, username3)
  ethAddresses = username:gsub("%s+", "")
  etherscanApiKey = password
end

function ListAccounts (knownAccounts)
  local account = {
    name = "Ethereum with Erc20-Tokens",
    accountNumber = "Crypto Asset Ethereum with Erc20-Tokens",
    currency = currency,
    portfolio = true,
    type = "AccountTypePortfolio"
  }

  return {account}
end

function RefreshAccount (account, since)
  local s = {}

  for address in string.gmatch(ethAddresses, '([^,]+)') do

    -- Request Ethereum ETH itself
    fsym = "ETH"
    weiQuantity = requestWeiQuantityForEthAddress(address)
    ethQuantity = convertWeiToEth(weiQuantity)
    prices = requestPrice(fsym)

    s[#s+1] = {
      name = fsym .. " (" .. address .. ")",
      currency = nil,
      market = "cryptocompare",
      quantity = ethQuantity,
      price = prices[mmcurrency],
    }

    -- Request Token Balance and Price
    for fsym, contractaddress in pairs(symbolContractaddress) do

      balance = requestTokenBalanceForEthAddress(address, contractaddress)

      -- TODO get many prices at once into an array and just look into it here
      prices = requestPrice(fsym)

      if tonumber(balance) > 0 then
        s[#s+1] = {
          name = fsym .. " (" .. address .. ")",
          currency = nil,
          market = "cryptocompare",
          quantity = balance,
          price = prices[mmcurrency],
        }
      end

    end
  end

  return {securities = s}
end

function EndSession ()
end


-- Query Functions
function requestPrice(fsym)
  content = connection:request("GET", cryptocompareRequestUrl(fsym), {})
  json = JSON(content)

  return json:dictionary()
end

function requestTokenBalanceForEthAddress(ethAddress, contractaddress)
  content = connection:request("GET", etherscanTokenRequestUrl(ethAddress, contractaddress), {})
  json = JSON(content)

  return json:dictionary()["result"]
end

function requestWeiQuantityForEthAddress(ethAddress)
  content = connection:request("GET", etherscanRequestUrl(ethAddress), {})
  json = JSON(content)

  return json:dictionary()["result"]
end


-- Helper Functions
function contractaddressForSymbol(fsym)
  return symbolContractaddress[fsym] or fsym
end

function convertWeiToEth(wei)
  return wei / 1000000000000000000
end

function cryptocompareRequestUrl(fsym)
  minApiRoot = "https://min-api.cryptocompare.com/data/price?fsym="
  params = "&tsyms=" .. mmcurrency
  return minApiRoot .. fsym .. params
end

function etherscanRequestUrl(ethAddress)
  etherscanRoot = "https://api.etherscan.io/api?"
  params = "&module=account&action=balance&tag=latest"
  address = "&address=" .. ethAddress
  apiKey = "&apikey=" .. etherscanApiKey

  return etherscanRoot .. params .. address .. apiKey
end

function etherscanTokenRequestUrl(ethAddress, contractaddress)
  etherscanRoot = "https://api.etherscan.io/api?"
  params = "&module=account&action=tokenbalance"
  contract = "&contractaddress=" .. contractaddress
  address = "&address=" .. ethAddress
  tag = "&tag=latest"
  apiKey = "&apikey=" .. etherscanApiKey

  return etherscanRoot .. params .. contract .. address .. tag .. apiKey
end

-- SIGNATURE: MCwCFHqFoAJuLK5WpXOfdxj3tDjhiMhdAhRhaErDWGvA8eoQC04W4qoRRKWkKA==
