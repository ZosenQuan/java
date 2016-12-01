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

--��Ʒ���ն��гɱ�����
CREATE OR REPLACE PROCEDURE orcl_proc_productFMTM(
    p_productCode varchar2,        --��Ʒ����
    p_fundAccountCode varchar2,    --�ʽ��˻�
    p_exchangeCode varchar2,       --����������
    p_securityCode varchar2,       --֤ȯ����
    p_beginDate varchar2           --��ʼ����
)
AS
	--�������
	p_real_beginDate varchar2(10);  --�ɱ����㿪ʼ����
	p_jrnl_beginDate varchar2(10);  --��ˮ��ʼ����
BEGIN
--    begin
--      --��֤�ʽ���Ƿ���ڶ�Ӧ���˻�
--      select * bulk COLLECT into t_fundAccount from productCapital
--      where (coalesce(p_productCode,' ')=' ' or fn_charindex_dh(productCode, p_productCode)>0)
--      and (coalesce(p_fundAccountCode,' ')=' ' or fn_charindex_dh(fundAccountCode, p_fundAccountCode)>0);
--      --�����쳣ʱ���ش�����
--      EXCEPTION
--        WHEN NO_DATA_FOUND THEN
--        null;
--    end;
--    FOR V_INDEX IN t_fundAccount.FIRST .. t_fundAccount.LAST LOOP  
--        DBMS_OUTPUT.PUT_LINE(t_fundAccount(V_INDEX).fundAccountCode);  
--    END LOOP;
    --����ɱ����㿪ʼ����
	begin
		select itemValueText into p_real_beginDate from commonconfig where itemCode = '2003';
		if(coalesce(p_real_beginDate, ' ')=' ' and coalesce(p_beginDate, ' ')=' ') then
        	p_real_beginDate := '1990-01-01';
      	elsif((coalesce(p_beginDate, ' ')!=' ' and coalesce(p_real_beginDate, ' ')=' ')
      		or (coalesce(p_beginDate, ' ')!=' ' and coalesce(p_beginDate, ' ')!=' ' and p_beginDate>p_real_beginDate)) then
        	p_real_beginDate := p_beginDate;
      	end if;
    end;
    
    --���㿪ʼ����ǰһ������
    begin
    	select max(tradedate) into p_jrnl_beginDate from tradecalender where tradedate<p_real_beginDate;
    end;
    --ɾ����ʷ������ˮ����ڿ�ʼ���ڵļ�¼
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

    --����ʷ������ˮ����ܵ���ʼ���ڵ���ʷ�ֲֺͳɱ�
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
    
    --����ʷ�ʽ�֤ȯ��ˮ�����ÿ��Ľ�����ˮ
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
    
    --ȡ��ʷת��ת�������ݻ��ܵ���ʱ�� TODO
    
    --ȡ������ˮ�����ͽ������������ѿ����˻�
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
    
    --�ѿ����˻���ʱ��ͺ�����ˮ��ʱ����left join�ó�������Ҫ��������ն�����ˮ,�������ں��ȿ���ƽ����
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

    --�����㷨���ƶ�ƽ���ɱ��䶯��ƽ��ӯ������
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
        
        --����ǵ�һ����¼���ߺ���һ����¼����ͬһ���ͣ���ʼ���������ɽ��������ܡ��ɱ����ܡ��������ڣ�����ֱ�Ӱ���ƽ�ֽ����ƶ�ƽ���ɱ����㷨��ӯ���ļ���
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
        
        --������ˮ�Ժ�Ŀռ�¼ȫ������
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
        	--���д���
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
                  r_key.productCode, -- ��Ʒ����
                  r_key.fundAccountCode, -- �ʽ��˻�����
                  r_key.currencyCode, -- ���Ҵ���
                  r_key.exchangeCode, -- ����������
                  r_key.securityCode, -- ֤ȯ����
                  r_key.securityCode, -- ԭʼ֤ȯ����
                  r_key.securityTradeTypeCode, -- ֤ȯ�������ʹ���
                  r_key.marketLevelCode, -- �г���Դ
                  ' ', -- ������־
                  'F1', -- ҵ������
                  ' ', -- ��ƽ�ֱ�־
                  r_key.hedgeFlagCode, -- Ͷ����־
                  r_key.longShortFlagCode, -- �ֲַ����־
                  '8200', -- ֤ȯҵ��������
                  0, -- �ɽ�����
                  p_settlePrice, -- �ɽ��۸�
                  0, -- �ɽ�������
                  0, -- �ɽ����׷��ý��
                  0, -- �ʽ�����
                  p_cost, -- �ֲֳɱ����䶯
                  p_cost-p_cost1, -- �ֲ�ռ�óɱ����䶯
                  p_cost1, -- �ֲ�ʵ��ӯ���䶯
                  p_cost, -- Ͷ�ʳɱ����䶯
                  p_cost-p_cost1, -- Ͷ��ռ�óɱ����䶯
                  p_cost1 -- Ͷ��ʵ��ӯ���䶯
              );
              
              --ӯ�������ʽ�֤ȯ��ˮ��
              select PRODUCTRAWJRNLHISTS.nextval into p_sequen from dual;
              insert into productRawJrnlHist values(
                  p_sequen, -- ��¼���
                  p_everyDay, -- ��������
                  case when p_cost1>0 then '8070' else '8071' end, -- ֤ȯҵ��������
                  ' ', -- ������־
                  'F1', -- ҵ������
                  ' ', -- ��ƽ�ֱ�־
                  r_key.hedgeFlagCode, -- Ͷ����־
                  ' ', -- ���ұ�־
                  ' ', -- ��ʼ֤ȯҵ�����
                  ' ', -- Ӫҵ����ҵ�����
                  ' ', -- Ӫҵ����ҵ������
                  ' ', -- Ӫҵ����ˮ��
                  r_key.productCode, -- ��Ʒ����
                  r_key.fundAccountCode, -- �ʽ��˺Ŵ���
                  r_key.currencyCode, -- ���Ҵ���
                  p_cost1, -- �ʽ�����
                  0, -- �ʽ𱾴����
                  r_key.exchangeCode, -- ����������
                  ' ', -- ֤ȯ�˻�����
                  r_key.securityCode, -- ֤ȯ����
                  r_key.securityCode, -- ԭʼ֤ȯ����
                  r_key.securityCode, -- ֤ȯ����
                  r_key.securityTradeTypeCode, -- ֤ȯ����������
                  0, -- �ɽ�����
                  0, -- �ֱֲ������
                  0, -- �ɽ��۸�
                  '0', -- ������Դ
                  '2', -- �г���Դ
                  null, -- ����Ա����
                  sysdate, -- ��������ʱ��
                  ' ' -- ��ע��Ϣ
                  );
            end;
            p_everyDay := r_key.settleDate;
          end if;
          
          if(r_key.matchQty is null) then
          	  p_everyDay := r_key.settleDate;
          	  continue;
          end if;
          
          --������ճֲ� = 0���򽨲�����=������¼���ڣ����򽨲�����=��ʷ��������
          if(r_key.openCloseFlagCode = '1')then --�����ƶ�ƽ���ɱ�ӯ������
          	if(p_matchQty=0) then
                p_createPosiDate :=r_key.settleDate;
            end if;
            p_matchQty := p_matchQty + r_key.matchQty;
            p_costChgAmt := p_costChgAmt + r_key.costChgAmt;
            --�����ƶ�ƽ���ɱ�=����ɽ���� ����ռ�óɱ�=����ɽ���� ����ӯ��=0
            begin
              select productCheckJrnlFHistS.nextval into p_sequen from dual;
              insert into productCheckJrnlFHist values(
                  p_sequen,
                  p_createPosiDate,
                  r_key.settleDate,
                  r_key.productCode, -- ��Ʒ����
                  r_key.fundAccountCode, -- �ʽ��˻�����
                  r_key.currencyCode, -- ���Ҵ���
                  r_key.exchangeCode, -- ����������
                  r_key.securityCode, -- ֤ȯ����
                  r_key.securityCode, -- ԭʼ֤ȯ����
                  r_key.securityTradeTypeCode, -- ֤ȯ�������ʹ���
                  r_key.marketLevelCode, -- �г���Դ
                  r_key.buySellFlagCode, -- ������־
                  'F1', -- ҵ������
                  r_key.openCloseFlagCode, -- ��ƽ�ֱ�־
                  r_key.hedgeFlagCode, -- Ͷ����־
                  r_key.longShortFlagCode, -- �ֲַ����־
                  case when r_key.longShortFlagCode='L' then '601' else '603' end, -- ֤ȯҵ��������
                  r_key.matchQty, -- �ɽ�����
                  -r_key.matchSettleAmt/(r_key.matchQty*p_contractValue), -- �ɽ��۸�
                  r_key.matchSettleAmt, -- �ɽ�������
                  r_key.matchTradeFeeAmt, -- �ɽ����׷��ý��
                  r_key.cashCurrentSettleAmt, -- �ʽ�����
                  r_key.costChgAmt, -- �ֲֳɱ����䶯
                  -r_key.matchSettleAmt, -- �ֲ�ռ�óɱ����䶯
                  0, -- �ֲ�ʵ��ӯ���䶯
                  r_key.costChgAmt, -- Ͷ�ʳɱ����䶯
                  -r_key.matchSettleAmt, -- Ͷ��ռ�óɱ����䶯
                  0 -- Ͷ��ʵ��ӯ���䶯
                  );
            end;
            p_everyDay := r_key.settleDate;
          elsif(r_key.openCloseFlagCode!='1') then  --�����ƶ�ƽ���ɱ�ӯ������
            if(p_matchQty=0) then
                continue;
            end if;
            per_costChgAmt := (r_key.matchQty*p_costChgAmt)/ p_matchQty;
            p_costChgAmt := p_costChgAmt + per_costChgAmt;
            p_matchQty := p_matchQty + r_key.matchQty;
            --�ƶ�ƽ���ɱ� = ����ʷ�ƶ�ƽ���ɱ� + �����ƶ�ƽ���ɱ���/�ֲ�����
            --�����ƶ�ƽ���ɱ� = �������� * �ƶ�ƽ���ɱ�
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
                  r_key.productCode, -- ��Ʒ����
                  r_key.fundAccountCode, -- �ʽ��˻�����
                  r_key.currencyCode, -- ���Ҵ���
                  r_key.exchangeCode, -- ����������
                  r_key.securityCode, -- ֤ȯ����
                  r_key.securityCode, -- ԭʼ֤ȯ����
                  r_key.securityTradeTypeCode, -- ֤ȯ�������ʹ���
                  r_key.marketLevelCode, -- �г���Դ
                  r_key.buySellFlagCode, -- ������־
                  'F1', -- ҵ������
                  r_key.openCloseFlagCode, -- ��ƽ�ֱ�־
                  r_key.hedgeFlagCode, -- Ͷ����־
                  r_key.longShortFlagCode, -- �ֲַ����־
                  case when r_key.longShortFlagCode='L' then '602' else '604' end, -- ֤ȯҵ��������
                  r_key.matchQty, -- �ɽ�����
                  -r_key.matchSettleAmt/(r_key.matchQty*p_contractValue), -- �ɽ��۸�
                  r_key.matchSettleAmt, -- �ɽ�������
                  r_key.matchTradeFeeAmt, -- �ɽ����׷��ý��
                  r_key.cashCurrentSettleAmt, -- �ʽ�����
                  per_costChgAmt, -- �ֲֳɱ����䶯
                  -r_key.matchSettleAmt, -- �ֲ�ռ�óɱ����䶯
                  p_cost, -- �ֲ�ʵ��ӯ���䶯
                  per_costChgAmt, -- Ͷ�ʳɱ����䶯
                  -r_key.matchSettleAmt, -- Ͷ��ռ�óɱ����䶯
                  p_cost -- Ͷ��ʵ��ӯ���䶯
                  );
              --ӯ�������ʽ�֤ȯ��ˮ��
              select PRODUCTRAWJRNLHISTS.nextval into p_sequen from dual;
              insert into productRawJrnlHist values(
                  p_sequen, -- ��¼���
                  r_key.settleDate, -- ��������
                  case when p_cost>0 then '8072' else '8073' end, -- ֤ȯҵ��������
                  ' ', -- ������־
                  'F1', -- ҵ������
                  ' ', -- ��ƽ�ֱ�־
                  r_key.hedgeFlagCode, -- Ͷ����־
                  ' ', -- ���ұ�־
                  ' ', -- ��ʼ֤ȯҵ�����
                  ' ', -- Ӫҵ����ҵ�����
                  ' ', -- Ӫҵ����ҵ������
                  ' ', -- Ӫҵ����ˮ��
                  r_key.productCode, -- ��Ʒ����
                  r_key.fundAccountCode, -- �ʽ��˺Ŵ���
                  r_key.currencyCode, -- ���Ҵ���
                  p_cost, -- �ʽ�����
                  0, -- �ʽ𱾴����
                  r_key.exchangeCode, -- ����������
                  ' ', -- ֤ȯ�˻�����
                  r_key.securityCode, -- ֤ȯ����
                  r_key.securityCode, -- ԭʼ֤ȯ����
                  r_key.securityCode, -- ֤ȯ����
                  r_key.securityTradeTypeCode, -- ֤ȯ����������
                  0, -- �ɽ�����
                  0, -- �ֱֲ������
                  0, -- �ɽ��۸�
                  '0', -- ������Դ
                  '2', -- �г���Դ
                  null, -- ����Ա����
                  sysdate, -- ��������ʱ��
                  ' ' -- ��ע��Ϣ
                  );
            end;
            if(r_key.openCloseFlagCode='G') then --������ˮ����
              p_finalDate := r_key.settleDate;
            end if;
            p_everyDay := r_key.settleDate;
          end if;
        end if;
      end loop;
    end;
    commit;  --�洢���̽���ǰ��commit�Ǳ���ģ���Ϊ��ʱ��Ĭ��Ϊ���񼶵ģ����������commit�´�ִ�д洢�����п�����ʱ������δ���
END orcl_proc_productFMTM;
/