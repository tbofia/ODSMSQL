DECLARE @start_dt DATETIME ,
    @end_dt DATETIME

SET @end_dt = ( SELECT MAX(vh.TransactionDate)
                 FROM   dbo.Vpn_Billing_History vh
               )


SET @end_dt = ( SELECT DATEADD(MONTH, DATEDIFF(MONTH, 0, @end_dt), 0)
               ) 
SET @start_dt = DATEADD(MONTH, -1, @end_dt)
                 


IF OBJECT_ID('tempdb..#Credit', 'U') IS NOT NULL
    DROP TABLE #Credit;


CREATE TABLE dbo.#Credit
    (
      Customer NVARCHAR(100) NULL ,
      TransactionID BIGINT NOT NULL ,
      Period DATETIME NOT NULL ,
	  CV_Type NCHAR(5) NULL ,
	  Company VARCHAR(50) NULL ,
	  Office VARCHAR(40) NULL ,
      ActivityFlag VARCHAR(1) NULL ,
      BillableFlag VARCHAR(1) NOT NULL ,
      Network VARCHAR(50) NULL ,
      BillIdNo INT NOT NULL ,
      Line_No SMALLINT NOT NULL ,
      TransactionDate DATETIME NOT NULL ,
      RepriceDate DATETIME NULL ,
      ProviderCharges MONEY NOT NULL ,
      DPAllowed MONEY NULL ,
      VPNAllowed MONEY NOT NULL ,
      Savings MONEY NOT NULL ,
      Credits MONEY NOT NULL ,
      NetSavings MONEY NOT NULL ,
      SOJ VARCHAR(2) NULL ,
      VpnId SMALLINT NOT NULL ,
      SubmittedToFinance BIT NULL ,
      IsInitialLoad BIT NULL ,
      ActivityFlagDesc VARCHAR(50) NULL ,
      Credit BIT NULL ,
      AdjProviderCharges MONEY NULL ,
      AdjDPAllowed MONEY NULL ,
      AdjVPNAllowed MONEY NULL ,
      AdjSavings MONEY NULL ,
      AdjCredits MONEY NULL ,
      AdjNetSavings MONEY NULL ,
      BillType VARCHAR(4) NULL
    )

IF OBJECT_ID('tempdb..#EndnotesPerLine', 'U') IS NOT NULL
    DROP TABLE #EndnotesPerLine;

CREATE TABLE #EndnotesPerLine
    (
      BillIdNo INT NOT NULL ,
      Line_No SMALLINT NOT NULL ,
      Records BIGINT NULL
    )

ALTER TABLE #EndnotesPerLine ADD PRIMARY KEY (BillIdNo,Line_No)
 


IF OBJECT_ID('tempdb..#ActivityFlag', 'U') IS NOT NULL
    DROP TABLE #ActivityFlag;

IF OBJECT_ID('tempdb..#ActivityFlag', 'U') IS NULL
    BEGIN
        CREATE TABLE #ActivityFlag
            (
              ACTIVITY_FLAG CHAR(1) NOT NULL ,
              AF_DESCRIPTION VARCHAR(50) NULL ,
              DATA_SOURCE NCHAR(2) NULL ,
              DEFAULT_BILLABLE BIT NULL ,
              CREDIT BIT
            )
       
    END

ALTER TABLE #ActivityFlag ADD PRIMARY KEY CLUSTERED (ACTIVITY_FLAG);

INSERT #ActivityFlag (ACTIVITY_FLAG, AF_DESCRIPTION, DATA_SOURCE, DEFAULT_BILLABLE, CREDIT) VALUES (N'B', N'Double Billed', N'SB', 0, 0)
INSERT #ActivityFlag (ACTIVITY_FLAG, AF_DESCRIPTION, DATA_SOURCE, DEFAULT_BILLABLE, CREDIT) VALUES (N'C', N'Credit', N'SB', 1, 1)
INSERT #ActivityFlag (ACTIVITY_FLAG, AF_DESCRIPTION, DATA_SOURCE, DEFAULT_BILLABLE, CREDIT) VALUES (N'D', N'Deleted', N'SB', 1, 1)
INSERT #ActivityFlag (ACTIVITY_FLAG, AF_DESCRIPTION, DATA_SOURCE, DEFAULT_BILLABLE, CREDIT) VALUES (N'E', N'Exclude - Submit Billed Previously', N'SB', 0, 0)
INSERT #ActivityFlag (ACTIVITY_FLAG, AF_DESCRIPTION, DATA_SOURCE, DEFAULT_BILLABLE, CREDIT) VALUES (N'F', N'Network 0 Bill', N'SB', 0, 0)
INSERT #ActivityFlag (ACTIVITY_FLAG, AF_DESCRIPTION, DATA_SOURCE, DEFAULT_BILLABLE, CREDIT) VALUES (N'I', N'Invalid Credit', N'SB', 1, 1)
INSERT #ActivityFlag (ACTIVITY_FLAG, AF_DESCRIPTION, DATA_SOURCE, DEFAULT_BILLABLE, CREDIT) VALUES (N'M', N'Manual Savings', N'SB', 0, 0)
INSERT #ActivityFlag (ACTIVITY_FLAG, AF_DESCRIPTION, DATA_SOURCE, DEFAULT_BILLABLE, CREDIT) VALUES (N'N', N'Unclassified', N'SB', 0, 0)
INSERT #ActivityFlag (ACTIVITY_FLAG, AF_DESCRIPTION, DATA_SOURCE, DEFAULT_BILLABLE, CREDIT) VALUES (N'O', N'Invalid Credit Over 90 Days', N'SB', 0, 1)
INSERT #ActivityFlag (ACTIVITY_FLAG, AF_DESCRIPTION, DATA_SOURCE, DEFAULT_BILLABLE, CREDIT) VALUES (N'P', N'Reconsideration DP Generated', N'SB', 1, 1)
INSERT #ActivityFlag (ACTIVITY_FLAG, AF_DESCRIPTION, DATA_SOURCE, DEFAULT_BILLABLE, CREDIT) VALUES (N'R', N'Reconsideration - Bill Sent To Network', N'SB', 1, 1)
INSERT #ActivityFlag (ACTIVITY_FLAG, AF_DESCRIPTION, DATA_SOURCE, DEFAULT_BILLABLE, CREDIT) VALUES (N'S', N'Savings', N'SB', 1, 0)
INSERT #ActivityFlag (ACTIVITY_FLAG, AF_DESCRIPTION, DATA_SOURCE, DEFAULT_BILLABLE, CREDIT) VALUES (N'V', N'Bill moved to a different provider', N'SB', 1, 1)
INSERT #ActivityFlag (ACTIVITY_FLAG, AF_DESCRIPTION, DATA_SOURCE, DEFAULT_BILLABLE, CREDIT) VALUES (N'X', N'Credit has valid end note over but  90 days', N'SB', 0, 1)
INSERT #ActivityFlag (ACTIVITY_FLAG, AF_DESCRIPTION, DATA_SOURCE, DEFAULT_BILLABLE, CREDIT) VALUES (N'Y', N'Sequence Number Reversal', N'SB', 0, 1)
INSERT #ActivityFlag (ACTIVITY_FLAG, AF_DESCRIPTION, DATA_SOURCE, DEFAULT_BILLABLE, CREDIT) VALUES (N'Z', N'Deleted Over 90 Days', N'SB', 0, 1)



INSERT  INTO #Credit
        ( Customer ,
          TransactionID ,
          Period ,
          ActivityFlag ,
          BillableFlag ,
          Network ,
          BillIdNo ,
          Line_No ,
          TransactionDate ,
          RepriceDate ,
          ProviderCharges ,
          DPAllowed ,
          VPNAllowed ,
          Savings ,
          CREDITS ,
          NetSavings ,
          SOJ ,
          VpnId ,
          SubmittedToFinance ,
          IsInitialLoad ,
          ActivityFlagDesc ,
          CREDIT ,
          AdjProviderCharges ,
          AdjDPAllowed ,
          AdjVPNAllowed ,
          AdjSavings ,
          AdjCredits ,
          AdjNetSavings ,
          BillType
        )
        SELECT  REPLACE(DB_NAME(), 'mmedical_', '') AS Customer ,
                vh.TransactionID ,
                vh.Period ,
                vh.ActivityFlag ,
                vh.BillableFlag ,
                vh.Network ,
                vh.BillIdNo ,
                vh.Line_No ,
                vh.TransactionDate ,
                vh.RepriceDate ,
                vh.ProviderCharges ,
                vh.DPAllowed ,
                vh.VPNAllowed ,
                vh.Savings ,
                vh.Credits ,
                vh.NetSavings ,
                vh.SOJ ,
                vh.VpnId ,
                vh.SubmittedToFinance ,
                vh.IsInitialLoad ,
                af.AF_DESCRIPTION ,
                af.CREDIT ,
                0 ,
                0 ,
                0 ,
                0 ,
                0 ,
                0 ,
                CASE WHEN ( CASE WHEN bh.Flags & 4096 > 0 THEN 'UB'
                                 ELSE 'HCFA'
                            END ) IS NULL THEN 'NA'
                     ELSE ( CASE WHEN bh.Flags & 4096 > 0 THEN 'UB'
                                 ELSE 'HCFA'
                            END )
                END AS BillType
        FROM    dbo.Vpn_Billing_History vh
                INNER JOIN #ActivityFlag af ON af.ACTIVITY_FLAG = vh.ActivityFlag
                LEFT OUTER JOIN dbo.BILL_HDR bh ON bh.BillIDNo = vh.BillIdNo
        WHERE   vh.TransactionDate >= @start_dt
                AND vh.TransactionDate < @end_dt
                AND af.CREDIT = 1 

				


INSERT  INTO #EndnotesPerLine
        ( BillIdNo ,
          Line_No ,
          Records
        )
        SELECT  c.BillIdNo ,
                c.Line_No ,
                COUNT(boe.OverrideEndNote) AS Records
        FROM    #Credit c
                JOIN dbo.Bills_OverrideEndNotes boe ON boe.BillIDNo = c.BillIdNo
                                                       AND boe.Line_No = c.Line_No
                JOIN dbo.rsn_Override ro ON ro.ReasonNumber = boe.OverrideEndNote
        WHERE   ro.CategoryIdNo <> 3
        GROUP BY c.BillIdNo ,
                c.Line_No
        ORDER BY c.BillIdNo ,
                c.Line_No


INSERT  INTO VPNAnalytics..VPNResults_Monthly_Credits
        ( Customer ,
          TransactionID ,
          Period ,
          ActivityFlag ,
          BillableFlag ,
          Network ,
          BillIdNo ,
          Line_No ,
          TransactionDate ,
          RepriceDate ,
          ProviderCharges ,
          DPAllowed ,
          VPNAllowed ,
          Savings ,
          CREDITS ,
          NetSavings ,
          SOJ ,
          VpnId ,
          SubmittedToFinance ,
          IsInitialLoad ,
          ActivityFlagDesc ,
          CREDIT ,
          AdjProviderCharges ,
          AdjDPAllowed ,
          AdjVPNAllowed ,
          AdjSavings ,
          AdjCredits ,
          AdjNetSavings ,
          BillType ,
          Records ,
          OverrideEndNote ,
          ShortDesc ,
          CreditReasonDesc
        )
        SELECT  cr.Customer ,
                cr.TransactionID ,
                cr.Period ,
                cr.ActivityFlag ,
                cr.BillableFlag ,
                cr.Network ,
                cr.BillIdNo ,
                cr.Line_No ,
                cr.TransactionDate ,
                cr.RepriceDate ,
                cr.ProviderCharges ,
                cr.DPAllowed ,
                cr.VPNAllowed ,
                cr.Savings ,
                cr.Credits ,
                cr.NetSavings ,
                cr.SOJ ,
                cr.VpnId ,
                cr.SubmittedToFinance ,
                cr.IsInitialLoad ,
                cr.ActivityFlagDesc ,
                cr.Credit ,
                CASE WHEN COALESCE(el.Records,0) = 0  THEN cr.ProviderCharges
                     ELSE ( cr.ProviderCharges / el.Records )
                END AS AdjProviderCharges ,
                CASE WHEN COALESCE(el.Records,0) = 0 THEN cr.DPAllowed
                     ELSE ( cr.DPAllowed / el.Records )
                END AS AdjDPAllowed ,
                CASE WHEN COALESCE(el.Records,0) = 0 THEN cr.VPNAllowed
                     ELSE ( cr.VPNAllowed / el.Records )
                END AS AdjVPNAllowed ,
                CASE WHEN COALESCE(el.Records,0) = 0 THEN cr.Savings
                     ELSE ( cr.Savings / el.Records )
                END AS AdjSavings ,
                CASE WHEN COALESCE(el.Records,0) = 0 THEN cr.Credits
                     ELSE ( cr.Credits / el.Records )
                END AS AdjCredits ,
                CASE WHEN COALESCE(el.Records,0) = 0 THEN cr.NetSavings
                     ELSE ( cr.NetSavings / el.Records )
                END AS AdjNetSavings ,
                cr.BillType ,
                COALESCE(el.Records, 0) AS Records ,
                COALESCE(z.OverrideEndNote, 0) AS OverrideEndNote ,
                z.ShortDesc ,
                z.CreditReasonDesc
        FROM    #Credit cr
                LEFT OUTER JOIN ( SELECT DISTINCT
                                            boe.BillIDNo ,
                                            boe.Line_No ,
                                            boe.OverrideEndNote ,
                                            ro.ShortDesc ,
                                            c.CreditReasonDesc
                                  FROM      dbo.Bills_OverrideEndNotes boe
                                            INNER JOIN dbo.rsn_Override ro ON ro.ReasonNumber = boe.OverrideEndNote
                                            LEFT OUTER JOIN dbo.CreditReasonOverrideENMap ce ON ce.OverrideEndnoteId = boe.OverrideEndNote
                                            LEFT OUTER JOIN dbo.CreditReason c ON c.CreditReasonId = ce.CreditReasonId
                                  WHERE     ro.CategoryIdNo <> 3
                                ) z ON z.BillIDNo = cr.BillIdNo
                                       AND z.Line_No = cr.Line_No
                LEFT OUTER JOIN #EndnotesPerLine el ON el.BillIdNo = cr.BillIdNo
                                                       AND el.Line_No = cr.Line_No