set serveroutput on;

declare
  cnt number;
begin
  cnt := 0;
  select count(*) into cnt from user_tables where table_name = upper('temp_ProductCheckJrnlFHist');
  if cnt = 1 then
    execute immediate 'drop table temp_ProductCheckJrnlFHist';
  end if;
end;
/

create global temporary table temp_ProductCheckJrnlFHist as
(
  select settleDate,productCode,fundAccountCode,exchangeCode,securityCode,createPosiDate,marketLevelCode,hedgeFlagCode,longShortFlagCode,
  securityTradeTypeCode,currencyCode,buysellflagcode,opencloseflagcode,matchQty,costChgAmt,matchSettleAmt,matchTradeFeeAmt,cashCurrentSettleAmt
      from ProductCheckJrnlFHist where 0=1
)
/

declare
  cnt number;
begin
  cnt := 0;
  select count(*) into cnt from user_tables where table_name = upper('cross_ProductCheckJrnlFHist');
  if cnt = 1 then
    execute immediate 'drop table cross_ProductCheckJrnlFHist';
  end if;
end;
/

create global temporary table cross_ProductCheckJrnlFHist as
(
  select settleDate,productCode,fundAccountCode,exchangeCode,securityCode,marketLevelCode,hedgeFlagCode,longShortFlagCode,
  securityTradeTypeCode,currencyCode
      from ProductCheckJrnlFHist where 0=1
)
/

declare
  cnt number;
begin
  cnt := 0;
  select count(*) into cnt from user_tables where table_name = upper('res_ProductCheckJrnlFHist');
  if cnt = 1 then
    execute immediate 'drop table res_ProductCheckJrnlFHist';
  end if;
end;
/

create global temporary table res_ProductCheckJrnlFHist
( 
    SETTLEDATE               VARCHAR2(10) not null, 
    PRODUCTCODE              VARCHAR2(30) not null, 
    FUNDACCOUNTCODE          VARCHAR2(30) not null, 
    EXCHANGECODE             VARCHAR2(4) not null,  
    SECURITYCODE             VARCHAR2(40) not null, 
    CREATEPOSIDATE           VARCHAR2(10), 
    MARKETLEVELCODE          VARCHAR2(1) not null,
    HEDGEFLAGCODE            VARCHAR2(1) not null,
    LONGSHORTFLAGCODE        VARCHAR2(1) not null,
    SECURITYTRADETYPECODE    VARCHAR2(30) not null,
    CURRENCYCODE             VARCHAR2(3) not null,
    BUYSELLFLAGCODE          VARCHAR2(1),
    OPENCLOSEFLAGCODE        VARCHAR2(1),
    MATCHQTY                 NUMBER(19,4),
    COSTCHGAMT               NUMBER(19,4),
    MATCHSETTLEAMT           NUMBER(19,4),
    MATCHTRADEFEEAMT         NUMBER(19,4),
    CASHCURRENTSETTLEAMT     NUMBER(19,4)
)
/

--产品逐日盯市成本计算
CREATE OR REPLACE PROCEDURE orcl_proc_productFMTM(
    p_productCode varchar2,        --产品代码
    p_fundAccountCode varchar2,    --资金账户
    p_exchangeCode varchar2,       --交易所代码
    p_securityCode varchar2,       --证券代码
    p_beginDate varchar2           --开始日期
)
AS
	--定义变量
	p_real_beginDate varchar2(10);  --成本计算开始日期
	p_jrnl_beginDate varchar2(10);  --流水开始日期
BEGIN
--    begin
--      --验证资金表是否存在对应的账户
--      select * bulk COLLECT into t_fundAccount from productCapital
--      where (coalesce(p_productCode,' ')=' ' or fn_charindex_dh(productCode, p_productCode)>0)
--      and (coalesce(p_fundAccountCode,' ')=' ' or fn_charindex_dh(fundAccountCode, p_fundAccountCode)>0);
--      --发生异常时返回错误码
--      EXCEPTION
--        WHEN NO_DATA_FOUND THEN
--        null;
--    end;
--    FOR V_INDEX IN t_fundAccount.FIRST .. t_fundAccount.LAST LOOP  
--        DBMS_OUTPUT.PUT_LINE(t_fundAccount(V_INDEX).fundAccountCode);  
--    END LOOP;
    --计算成本计算开始日期
	begin
		select itemValueText into p_real_beginDate from commonconfig where itemCode = '2003';
		if(coalesce(p_real_beginDate, ' ')=' ' and coalesce(p_beginDate, ' ')=' ') then
        	p_real_beginDate := '1990-01-01';
      	elsif((coalesce(p_beginDate, ' ')!=' ' and coalesce(p_real_beginDate, ' ')=' ')
      		or (coalesce(p_beginDate, ' ')!=' ' and coalesce(p_beginDate, ' ')!=' ' and p_beginDate>p_real_beginDate)) then
        	p_real_beginDate := p_beginDate;
      	end if;
    end;
    
    --计算开始日期前一交易日
    begin
    	select max(tradedate) into p_jrnl_beginDate from tradecalender where tradedate<p_real_beginDate;
    end;
    --删除历史核算流水表大于开始日期的纪录
    begin
    	delete 
      	from ProductCheckJrnlFHist
      	where settleDate>=p_real_beginDate
        	and (coalesce(p_productCode, ' ')=' ' or fn_charindex_dh(productCode, p_productCode)>0)
        	and (coalesce(p_fundAccountCode, ' ')=' ' or fn_charindex_dh(fundAccountCode, p_fundAccountCode)>0)
        	and (coalesce(p_exchangeCode, ' ')=' ' or fn_charindex_dh(exchangeCode, p_exchangeCode)>0)
        	and (coalesce(p_securityCode, ' ')=' ' or fn_charindex_dh(securityCode, p_securityCode)>0);
        
        delete 
      	from ProductRawJrnlHist
      	where settleDate>=p_real_beginDate
        	and (coalesce(p_productCode, ' ')=' ' or fn_charindex_dh(productCode, p_productCode)>0)
        	and (coalesce(p_fundAccountCode, ' ')=' ' or fn_charindex_dh(fundAccountCode, p_fundAccountCode)>0)
        	and (coalesce(p_exchangeCode, ' ')=' ' or fn_charindex_dh(exchangeCode, p_exchangeCode)>0)
        	and (coalesce(p_securityCode, ' ')=' ' or fn_charindex_dh(securityCode, p_securityCode)>0)
          and securityBusinessTypeCode in ('8070','8071','8072','8073');
    end;

    --从历史核算流水表汇总到开始日期的历史持仓和成本
    begin
	    insert into temp_ProductCheckJrnlFHist
	    select max(p_jrnl_beginDate),productCode,fundAccountCode,exchangeCode,securityCode,max(createPosiDate),
	    	marketLevelCode,hedgeFlagCode,longShortFlagCode,securityTradeTypeCode,currencyCode,
	    	max(case when longshortflagcode='L' then 'B' else 'S' end), max('1'),
	    	sum(matchQty),sum(costChgAmt),sum(0),sum(0),sum(0)
	    from ProductCheckJrnlFHist
      	where settleDate<p_real_beginDate
           	and (coalesce(p_productCode, ' ')=' ' or fn_charindex_dh(productCode, p_productCode)>0)
           	and (coalesce(p_fundAccountCode, ' ')=' ' or fn_charindex_dh(fundAccountCode, p_fundAccountCode)>0)
           	and (coalesce(p_exchangeCode, ' ')=' ' or fn_charindex_dh(exchangeCode, p_exchangeCode)>0)
           	and (coalesce(p_securityCode, ' ')=' ' or fn_charindex_dh(securityCode, p_securityCode)>0)
           	and coalesce(exchangeCode,' ')!=' ' and coalesce(securityCode,' ')!=' ' and coalesce(buySellFlagCode,' ')!=' ' 
       	group by productCode,fundAccountCode,exchangeCode,securityCode,securityTradeTypeCode,marketLevelCode,hedgeFlagCode,currencyCode,longShortFlagCode
      	having sum(matchqty)>0;
      	EXCEPTION WHEN NO_DATA_FOUND THEN
        	null;
    end;
    
    --从历史资金证券流水表汇总每天的交易流水
    begin
      	insert into temp_ProductCheckJrnlFHist
      	select settledate,productCode,fundAccountCode,exchangeCode,securityCode,settledate,marketLevelCode,
        	hedgeFlagCode,max(case when((buysellflagcode='B' and opencloseflagcode='1') or (buysellflagcode='S' and opencloseflagcode!='1')) then 'L' else 'S' end),
        	securityTradeTypeCode,currencyCode,buysellflagCode,opencloseflagcode,
        	sum(matchQty),sum(case when opencloseflagcode='1' then -matchSettleAmt else 0 end),
        	sum(matchSettleAmt),sum(matchTradeFeeAmt),sum(cashCurrentSettleAmt)
      	from productRawJrnlFHist
      	where settleDate>=p_real_beginDate
        	and (coalesce(p_productCode, ' ')=' ' or fn_charindex_dh(productCode, p_productCode)>0)
        	and (coalesce(p_fundAccountCode, ' ')=' ' or fn_charindex_dh(fundAccountCode, p_fundAccountCode)>0)
        	and (coalesce(p_exchangeCode, ' ')=' ' or fn_charindex_dh(exchangeCode, p_exchangeCode)>0)
        	and (coalesce(p_securityCode, ' ')=' ' or fn_charindex_dh(securityCode, p_securityCode)>0)
        	and coalesce(exchangeCode,' ')!=' ' and coalesce(securityCode,' ')!=' '
      	group by settledate,productCode,fundAccountCode,exchangeCode,securityCode,buysellflagCode,opencloseflagcode,
        	securityTradeTypeCode,marketLevelCode,hedgeFlagCode,currencyCode;
      	EXCEPTION WHEN NO_DATA_FOUND THEN
        	null;
    end;
    
    --取历史转入转出表数据汇总到临时表 TODO
    
    --取核算流水主键和交易日历表做笛卡尔乘积
    begin
      	insert into cross_ProductCheckJrnlFHist
      	select distinct b.tradedate,a.productCode,a.fundAccountCode,a.exchangeCode,a.securityCode,a.marketLevelCode,
        	a.hedgeFlagCode,a.longshortflagcode,a.securityTradeTypeCode,a.currencyCode
        	--case when((buysellflagcode='B' and opencloseflagcode='1') or (buysellflagcode='S' and opencloseflagcode!='1')) then 'L' else 'S' end as longshortflagcode
      	from temp_ProductCheckJrnlFHist a 
      	cross join tradecalender b
      	where b.tradedate>=p_jrnl_beginDate and b.tradedate<=to_char(sysdate,'yyyy-MM-dd');
      	EXCEPTION WHEN NO_DATA_FOUND THEN
        	null;
    end;
    
    --笛卡尔乘积临时表和核算流水临时表做left join得出最终需要处理的逐日盯市流水,并按日期和先开后平排序
    begin
      	insert into res_ProductCheckJrnlFHist
      	select a.settleDate,a.productCode,a.fundAccountCode,a.exchangeCode,a.securityCode,b.createPosiDate,a.marketLevelCode,a.hedgeFlagCode,a.longShortFlagCode,
      		a.securityTradeTypeCode,a.currencyCode,buysellflagcode,opencloseflagcode,matchQty,costChgAmt,matchSettleAmt,matchTradeFeeAmt,cashCurrentSettleAmt
      	from cross_ProductCheckJrnlFHist a 
      	left join temp_ProductCheckJrnlFHist b
        	on a.settleDate=b.settleDate
        	and a.productCode=b.productCode
        	and a.fundAccountCode=b.fundAccountCode
        	and a.exchangeCode=b.exchangeCode
        	and a.securityCode=b.securityCode
        	and a.marketLevelCode=b.marketLevelCode
        	and a.hedgeFlagCode=b.hedgeFlagCode
        	and a.longShortFlagCode=b.longShortFlagCode
        	and a.securityTradeTypeCode=b.securityTradeTypeCode
        	and a.currencyCode=b.currencyCode
      	order by productCode,fundAccountCode,exchangeCode,securityCode,securityTradeTypeCode,marketLevelCode,
        	hedgeFlagCode,currencyCode,longShortFlagCode,settledate,opencloseflagcode;
      	EXCEPTION WHEN NO_DATA_FOUND THEN
        	null;
    end;

    --核心算法：移动平均成本变动及平仓盈亏计算
    declare
      	key_word varchar2(255);
      	key_mid varchar2(255);
      	p_matchQty number(19,0);
      	p_costChgAmt number(19,4);
      	per_costChgAmt number(19,4);
      	p_createPosiDate varchar2(10);
      	p_sequen number(19,0);
      	p_finalDate varchar2(10);
      	p_everyDay varchar2(10);
      	p_contractValue number(19,4);
        p_cost number(19,4);
    begin
      	for r_key in (select * from res_ProductCheckJrnlFHist) loop
        	key_word:=r_key.productcode||','||r_key.fundAccountCode||','||r_key.exchangeCode||','||r_key.securityCode||','||r_key.securityTradeTypeCode||',
        	'||r_key.marketLevelCode||','||r_key.hedgeFlagCode||','||r_key.currencyCode||','||r_key.longShortFlagCode;
        
        --如果是第一条记录或者和上一条记录不是同一类型，初始化主键、成交数量汇总、成本汇总、建仓日期，否则直接按开平仓进行移动平均成本的算法和盈亏的计算
        if (key_mid is null or key_mid!=key_word) then
          	if(r_key.matchQty is null) then
            	continue;
          	end if;
          	
          	key_mid:=key_word;
          	p_createPosiDate :=r_key.createPosiDate;
          	p_finalDate := null;
          	
          	if(r_key.settleDate<p_real_beginDate) then
            	p_matchQty := r_key.matchQty;
            	p_costChgAmt := r_key.costChgAmt;
            	continue;
          	else
            	p_matchQty := 0;
            	p_costChgAmt := 0;
          	end if;
        end if;
        
        --交割流水以后的空记录全部跳过
        if (p_finalDate is not null and r_key.settleDate>p_finalDate) then
          	continue;
        end if;
        --DBMS_OUTPUT.PUT_LINE(p_costChgAmt||','||p_matchQty);
        
        begin
            select contractMultiplierValue into p_contractValue  from securityDetailConfigFC
            where exchangeCode=r_key.exchangeCode and securityCode = r_key.securityCode;
            EXCEPTION WHEN NO_DATA_FOUND THEN
              null;
        end;
        if p_contractValue is null then
            begin
                select contractMultiplierValue into p_contractValue from securityDetailConfigFF
                where exchangeCode=r_key.exchangeCode and securityCode = r_key.securityCode;
                EXCEPTION WHEN NO_DATA_FOUND THEN
                  p_contractValue := 1;
            end;
        end if;
            
        if key_mid=key_word then
        	--盯市处理
          if(p_everyDay is not null and p_everyDay!=r_key.settleDate and p_matchQty!=0) then  
            declare
                p_settlePrice number(19,4);
                p_cost1 number(19,4);
            begin
              begin
                  select settlePrice into p_settlePrice from primaryQuotationFHist
                    where exchangeCode=r_key.exchangeCode and securityCode = r_key.securityCode and quotationDate = p_everyDay;
                  EXCEPTION WHEN NO_DATA_FOUND THEN
                    p_settlePrice := 0;
              end;
                
              p_cost := p_settlePrice*p_contractValue*p_matchQty-p_costChgAmt;
              p_costChgAmt := p_costChgAmt+p_cost;
                
              if r_key.longShortFlagCode='L' then
                  p_cost1:=p_cost;
              else
                  p_cost1:=-p_cost;
              end if;

              select productCheckJrnlFHistS.nextval into p_sequen from dual;
              insert into productCheckJrnlFHist values(
                  p_sequen,
                  ' ',
                  p_everyDay,
                  r_key.productCode, -- 产品代码
                  r_key.fundAccountCode, -- 资金账户代码
                  r_key.currencyCode, -- 货币代码
                  r_key.exchangeCode, -- 交易所代码
                  r_key.securityCode, -- 证券代码
                  r_key.securityCode, -- 原始证券代码
                  r_key.securityTradeTypeCode, -- 证券交易类型代码
                  r_key.marketLevelCode, -- 市场来源
                  ' ', -- 买卖标志
                  'F1', -- 业务子类
                  ' ', -- 开平仓标志
                  r_key.hedgeFlagCode, -- 投保标志
                  r_key.longShortFlagCode, -- 持仓方向标志
                  '8200', -- 证券业务类别代码
                  0, -- 成交数量
                  p_settlePrice, -- 成交价格
                  0, -- 成交结算金额
                  0, -- 成交交易费用金额
                  0, -- 资金发生数
                  p_cost, -- 持仓成本金额变动
                  p_cost-p_cost1, -- 持仓占用成本金额变动
                  p_cost1, -- 持仓实现盈亏变动
                  p_cost, -- 投资成本金额变动
                  p_cost-p_cost1, -- 投资占用成本金额变动
                  p_cost1 -- 投资实现盈亏变动
              );
              
              --盈亏插入资金证券流水表
              select PRODUCTRAWJRNLHISTS.nextval into p_sequen from dual;
              insert into productRawJrnlHist values(
                  p_sequen, -- 记录序号
                  p_everyDay, -- 交收日期
                  case when p_cost1>0 then '8070' else '8071' end, -- 证券业务类别代码
                  ' ', -- 买卖标志
                  'F1', -- 业务子类
                  ' ', -- 开平仓标志
                  r_key.hedgeFlagCode, -- 投保标志
                  ' ', -- 备兑标志
                  ' ', -- 初始证券业务类别
                  ' ', -- 营业部的业务代码
                  ' ', -- 营业部的业务名称
                  ' ', -- 营业部流水号
                  r_key.productCode, -- 产品代码
                  r_key.fundAccountCode, -- 资金账号代码
                  r_key.currencyCode, -- 货币代码
                  p_cost1, -- 资金发生数
                  0, -- 资金本次余额
                  r_key.exchangeCode, -- 交易所代码
                  ' ', -- 证券账户代码
                  r_key.securityCode, -- 证券代码
                  r_key.securityCode, -- 原始证券代码
                  r_key.securityCode, -- 证券名称
                  r_key.securityTradeTypeCode, -- 证券交易类别代码
                  0, -- 成交数量
                  0, -- 持仓本次余额
                  0, -- 成交价格
                  '0', -- 数据来源
                  '2', -- 市场来源
                  null, -- 操作员代码
                  sysdate, -- 操作日期时间
                  ' ' -- 备注信息
                  );
            end;
            p_everyDay := r_key.settleDate;
          end if;
          
          if(r_key.matchQty is null) then
          	  p_everyDay := r_key.settleDate;
          	  continue;
          end if;
          
          --如果昨日持仓 = 0，则建仓日期=本条记录日期，否则建仓日期=历史建仓日期
          if(r_key.openCloseFlagCode = '1')then --开仓移动平均成本盈亏计算
          	if(p_matchQty=0) then
                p_createPosiDate :=r_key.settleDate;
            end if;
            p_matchQty := p_matchQty + r_key.matchQty;
            p_costChgAmt := p_costChgAmt + r_key.costChgAmt;
            --买入移动平均成本=买入成交金额 买入占用成本=买入成交金额 买入盈亏=0
            begin
              select productCheckJrnlFHistS.nextval into p_sequen from dual;
              insert into productCheckJrnlFHist values(
                  p_sequen,
                  p_createPosiDate,
                  r_key.settleDate,
                  r_key.productCode, -- 产品代码
                  r_key.fundAccountCode, -- 资金账户代码
                  r_key.currencyCode, -- 货币代码
                  r_key.exchangeCode, -- 交易所代码
                  r_key.securityCode, -- 证券代码
                  r_key.securityCode, -- 原始证券代码
                  r_key.securityTradeTypeCode, -- 证券交易类型代码
                  r_key.marketLevelCode, -- 市场来源
                  r_key.buySellFlagCode, -- 买卖标志
                  'F1', -- 业务子类
                  r_key.openCloseFlagCode, -- 开平仓标志
                  r_key.hedgeFlagCode, -- 投保标志
                  r_key.longShortFlagCode, -- 持仓方向标志
                  case when r_key.longShortFlagCode='L' then '601' else '603' end, -- 证券业务类别代码
                  r_key.matchQty, -- 成交数量
                  -r_key.matchSettleAmt/(r_key.matchQty*p_contractValue), -- 成交价格
                  r_key.matchSettleAmt, -- 成交结算金额
                  r_key.matchTradeFeeAmt, -- 成交交易费用金额
                  r_key.cashCurrentSettleAmt, -- 资金发生数
                  r_key.costChgAmt, -- 持仓成本金额变动
                  -r_key.matchSettleAmt, -- 持仓占用成本金额变动
                  0, -- 持仓实现盈亏变动
                  r_key.costChgAmt, -- 投资成本金额变动
                  -r_key.matchSettleAmt, -- 投资占用成本金额变动
                  0 -- 投资实现盈亏变动
                  );
            end;
            p_everyDay := r_key.settleDate;
          elsif(r_key.openCloseFlagCode!='1') then  --卖出移动平均成本盈亏计算
            if(p_matchQty=0) then
                continue;
            end if;
            per_costChgAmt := (r_key.matchQty*p_costChgAmt)/ p_matchQty;
            p_costChgAmt := p_costChgAmt + per_costChgAmt;
            p_matchQty := p_matchQty + r_key.matchQty;
            --移动平均成本 = （历史移动平均成本 + 买入移动平均成本）/持仓数量
            --卖出移动平均成本 = 卖出数量 * 移动平均成本
            if r_key.longShortFlagCode='L' then
                p_cost:=abs(r_key.matchSettleAmt)-abs(per_costChgAmt);
            else
                p_cost:=abs(per_costChgAmt)-abs(r_key.matchSettleAmt);
            end if;
            begin
              select productCheckJrnlFHistS.nextval into p_sequen from dual;
              insert into productCheckJrnlFHist values(
                  p_sequen,
                  p_createPosiDate,
                  r_key.settleDate,
                  r_key.productCode, -- 产品代码
                  r_key.fundAccountCode, -- 资金账户代码
                  r_key.currencyCode, -- 货币代码
                  r_key.exchangeCode, -- 交易所代码
                  r_key.securityCode, -- 证券代码
                  r_key.securityCode, -- 原始证券代码
                  r_key.securityTradeTypeCode, -- 证券交易类型代码
                  r_key.marketLevelCode, -- 市场来源
                  r_key.buySellFlagCode, -- 买卖标志
                  'F1', -- 业务子类
                  r_key.openCloseFlagCode, -- 开平仓标志
                  r_key.hedgeFlagCode, -- 投保标志
                  r_key.longShortFlagCode, -- 持仓方向标志
                  case when r_key.longShortFlagCode='L' then '602' else '604' end, -- 证券业务类别代码
                  r_key.matchQty, -- 成交数量
                  -r_key.matchSettleAmt/(r_key.matchQty*p_contractValue), -- 成交价格
                  r_key.matchSettleAmt, -- 成交结算金额
                  r_key.matchTradeFeeAmt, -- 成交交易费用金额
                  r_key.cashCurrentSettleAmt, -- 资金发生数
                  per_costChgAmt, -- 持仓成本金额变动
                  -r_key.matchSettleAmt, -- 持仓占用成本金额变动
                  p_cost, -- 持仓实现盈亏变动
                  per_costChgAmt, -- 投资成本金额变动
                  -r_key.matchSettleAmt, -- 投资占用成本金额变动
                  p_cost -- 投资实现盈亏变动
                  );
              --盈亏插入资金证券流水表
              select PRODUCTRAWJRNLHISTS.nextval into p_sequen from dual;
              insert into productRawJrnlHist values(
                  p_sequen, -- 记录序号
                  r_key.settleDate, -- 交收日期
                  case when p_cost>0 then '8072' else '8073' end, -- 证券业务类别代码
                  ' ', -- 买卖标志
                  'F1', -- 业务子类
                  ' ', -- 开平仓标志
                  r_key.hedgeFlagCode, -- 投保标志
                  ' ', -- 备兑标志
                  ' ', -- 初始证券业务类别
                  ' ', -- 营业部的业务代码
                  ' ', -- 营业部的业务名称
                  ' ', -- 营业部流水号
                  r_key.productCode, -- 产品代码
                  r_key.fundAccountCode, -- 资金账号代码
                  r_key.currencyCode, -- 货币代码
                  p_cost, -- 资金发生数
                  0, -- 资金本次余额
                  r_key.exchangeCode, -- 交易所代码
                  ' ', -- 证券账户代码
                  r_key.securityCode, -- 证券代码
                  r_key.securityCode, -- 原始证券代码
                  r_key.securityCode, -- 证券名称
                  r_key.securityTradeTypeCode, -- 证券交易类别代码
                  0, -- 成交数量
                  0, -- 持仓本次余额
                  0, -- 成交价格
                  '0', -- 数据来源
                  '2', -- 市场来源
                  null, -- 操作员代码
                  sysdate, -- 操作日期时间
                  ' ' -- 备注信息
                  );
            end;
            if(r_key.openCloseFlagCode='G') then --交割流水处理
              p_finalDate := r_key.settleDate;
            end if;
            p_everyDay := r_key.settleDate;
          end if;
        end if;
      end loop;
    end;
    commit;  --存储过程结束前的commit是必须的，因为临时表默认为事务级的，如果不进行commit下次执行存储过程有可能临时表数据未清空
END orcl_proc_productFMTM;
/