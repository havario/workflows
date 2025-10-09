<script>
// 默认分组模式
if(!localStorage.getItem("showGroup")){
    localStorage.setItem("showGroup", true);
}
// 默认暗黑模式
if(!localStorage.getItem("theme")){
    localStorage.setItem("theme", 'dark');
}
// 默认半透明效果
if(!localStorage.getItem("semiTransparent")){
    localStorage.setItem("semiTransparent", 'true');
}
window.onload = function(){
const affLinks = {
  crunchbits: 'https://get.crunchbits.com/order/lblk-yearly-kvm-ssd-vps/84',
  rainyun: 'https://www.rainyun.com/MjYzMTk=_',
  colocrossing: 'https://cloud.colocrossing.com/aff.php?aff=316',
  racknerd: 'https://my.racknerd.com/aff.php?aff=9727',
}
const contacts = {
  main: 'telegram',
  animatedType: 'vertical',
  telegram: {
    label: 'TG',
    icon: 'telegram plane',
    url: 'https://t.me/bmqyChatBot'
  },
  qq: {
    label: 'QQ',
    icon: 'qq',
    url: 'https://wpa.qq.com/msgrd?V=3&Uin=88268459&Site=nezha.887776.xyz&menu=yes'
  },
  email: {
    label: 'Email',
    icon: 'mail',
    url: 'mailto:notice@bmqy.net'
  },
}
const extraData = {
  2: {
    pid: 0,
    shop: 'crunchbits',
    price: '$27.38',
    cycle: 'Year',
    start: '08/13/2023',
    expire: '08/13/2024',
    autoPay: '否'
  },
  15: {
    pid: 0,
    shop: 'crunchbits',
    price: '$22.69',
    cycle: 'Year',
    start: '04/08/2024',
    expire: '04/08/2025',
    autoPay: '否'
  },
  10: {
    pid: 358,
    shop: 'racknerd',
    price: '$10.98',
    cycle: 'Year',
    start: '11/14/2023',
    expire: '11/14/2024',
    autoPay: '否'
  },
  12: {
    pid: 23,
    shop: 'colocrossing',
    price: '$10.00',
    cycle: 'Year',
    start: '02/13/2024',
    expire: '02/13/2025',
    autoPay: '否'
  },
  13: {
    pid: 0,
    shop: 'rainyun',
    price: '￥245',
    cycle: 'Year',
    start: '07/03/2023',
    expire: '08/09/2024',
    autoPay: '否'
  },
  14: {
    pid: 0,
    shop: 'rainyun',
    price: 'P5500',
    cycle: 'Month',
    start: '12/27/2023',
    expire: '∞',
    autoPay: '是'
  },
}
const cycleNames = {
  '年付': 'year',
  '半年付': 'half',
  '季付': 'quarterly',
  '月付': 'month',
  '年': 'year',
  '半': 'half',
  '季': 'quarterly',
  '月': 'month',
  'Year': 'year',
  'Half': 'half',
  'Quarterly': 'quarterly',
  'Month': 'month',
  'Y': 'year',
  'H': 'half',
  'Q': 'quarterly',
  'M': 'month',
  'year': 'year',
  'half': 'half',
  'quarterly': 'quarterly',
  'month': 'month',
}
const cycleValues = {
  year: 365,
  half: 180,
  quarterly: 90,
  month: 30,
}
// 判断当前主题
const cookie = document.cookie;
let preferredTheme = document.body.innerHTML.match(/(?<=defaultTemplate: ")(default|server-status)(?=")/g) ? document.body.innerHTML.match(/(?<=defaultTemplate: ")(default|server-status)(?=")/g)[0] : 'default';
preferredTheme = document.cookie.match(/(server-status|default)/g) ? document.cookie.match(/(server-status|default)/g)[0] : preferredTheme;
  // 默认主题
  if(preferredTheme === 'default'){
    const cats = document.querySelectorAll('.ui.accordion');
    cats.forEach((e, i)=>{
      let $catsTitle = e.querySelector('.title');
      let ct = $catsTitle.innerText;
      ct = ct.trim();

      let $itemCard = e.querySelectorAll('.ui.card');
      let uiCardCount = $itemCard.length;
      $catsTitle.innerHTML = $catsTitle.innerHTML.replace(ct, ct+ ' ('+ uiCardCount +')');
      $itemCard.forEach((ee, ii)=>{
        let $content = ee.querySelector('.content');
        let $descriptionGrid = ee.querySelector('.description .ui.grid');
        let $itemTitle = $content.querySelector('.header');
        let id = ee.getAttribute('id');
        if(extraData[id]){
          let pid = extraData[id].pid;
          pid = parseInt(pid);
          let shop = extraData[id].shop;
          let price = extraData[id].price;
          let start = extraData[id].start;
          let expire = extraData[id].expire;
          let cycle = extraData[id].cycle;
          let autoPay = extraData[id].autoPay;
          let cycleName = cycleNames[cycle];
          let cycleValue = cycleValues[cycleName];
          let nowTime = parseInt(new Date().getTime() / 1000);
          let beginTime = parseInt(new Date(start).getTime() / 1000);
          if(autoPay && autoPay=='是'){
            let beginDate = new Date(start);
            let nowDate = new Date();
            let mSteps = {
              year: 12,
              half: 6,
              quarterly: 3,
              month: 1,
            }
            expire = beginDate.setMonth(beginDate.getMonth() + mSteps[cycleName]);
            expire = new Date(expire);
            while(expire.getTime() < nowDate.getTime()){
              expire = expire.setMonth(expire.getMonth() + mSteps[cycleName]);
              expire = new Date(expire);
            }
            expire = expire.toLocaleDateString();
          }
          let endTime = parseInt(new Date(expire).getTime() / 1000);

          // 购买同款按钮
          let $aButtonsBox = document.createElement('div');
          $aButtonsBox.setAttribute('style', 'margin-bottom: .5em;text-align:right;');
          let $aLinkButtons = document.createElement('div');
          $aLinkButtons.setAttribute('class', 'btn-buy-box ui buttons mini');
          let $aLinkBuy = document.createElement('a');
          $aLinkBuy.setAttribute('class', 'ui btn-buy button positive');
          $aLinkBuy.setAttribute('target', shop ? '_blank' : '');
          $aLinkBuy.innerHTML = '购买同款';
          $aLinkBuy.href = shop ? affLinks[shop] : 'javascript:void(0);';
          if(pid){
            $aLinkBuy.href += '&pid='+ pid;
          }
          if(price){
            // 购买价格行
            let $priceL = document.createElement('div');
            $priceL.setAttribute('class', 'three wide column');
            $priceL.innerHTML = '价格';
            $descriptionGrid.insertBefore($priceL, $descriptionGrid.childNodes[$descriptionGrid.childNodes.length-3]);
            let $priceR = document.createElement('div');
            $priceR.setAttribute('class', 'price-box thirteen wide column');
            $priceR.innerHTML = '<div class="ui red label"><i class="money bill alternate yellow icon"></i>'+ price +'<a class="detail">'+ cycle +'</a></div>';
            $descriptionGrid.insertBefore($priceR, $descriptionGrid.childNodes[$descriptionGrid.childNodes.length-3])
          }
          if(expire){
            // 到期日期行
            let $expireL = document.createElement('div');
            $expireL.setAttribute('class', 'three wide column');
            $expireL.innerHTML = '到期';
            $descriptionGrid.insertBefore($expireL, $descriptionGrid.childNodes[$descriptionGrid.childNodes.length-3])
            // 到期日期行右侧进度条
            let $expireR = document.createElement('div');
            let aTime = (nowTime-beginTime);
            let bTime = (endTime-beginTime);
            let cTime = parseInt(aTime / bTime * 100);
            let progressType = 'red';
            let textStyle = 'text-shadow: 0px 0px 5px #db2828;left:.5em;text-align: right;';
            if(expire === '∞'){
              progressType = 'success';
              textStyle = '';
            }
            $expireR.setAttribute('class', 'expire-box thirteen wide column');
            $expireR.innerHTML = '<div class="ui indicating progress '+ progressType +' active"><div class="bar" style="line-height: 1em !important;transition-duration: 300ms; min-width: unset; width: '+ cTime +'% !important;padding-left: 0.4em;"><div class="progress" style="'+ textStyle +'">'+ expire +'</div></div></div>';
            $descriptionGrid.insertBefore($expireR, $descriptionGrid.childNodes[$descriptionGrid.childNodes.length-3])
          }
          $aLinkButtons.append($aLinkBuy);
          let $aLinkOr = document.createElement('div');
          $aLinkOr.innerHTML = '<div class="or" data-text="or"></div>';
          $aLinkButtons.append($aLinkOr);
          // 购买同款按钮右侧联系方式
          let remainingAnimatedType = contacts['animatedType'];
          let priceValue = price.replace(/[$￥P€]/g, '');
          let priceUnit = price.match(/[$￥P€]/g)[0];
          let remainingDays = Math.floor((endTime - nowTime) / (24 * 60 * 60));
          let remainingPrice = parseFloat(priceValue) / cycleValue  * remainingDays;
          if(!remainingPrice){
            remainingPrice = 0;
          }
          remainingPrice = remainingPrice.toFixed(2);
          let mainContact = contacts['main'];
          // 购买同款按钮右侧主要联系方式显示剩余价值
          let $aLinkContactMain = document.createElement('a');
          $aLinkContactMain.setAttribute('class', 'contact-main ui button '+ remainingAnimatedType +' animated blue');
          $aLinkContactMain.setAttribute('target', '_blank');
          $aLinkContactMain.innerHTML = '<div class="hidden content" style="padding:0;" title="剩余价值">'+ contacts[mainContact].label +'议价</div><div class="visible content" style="padding:0;" title="剩余价值"><i class="'+ contacts[mainContact].icon +' icon" style="color:white;"></i>'+ priceUnit + remainingPrice +'</div>';
          $aLinkContactMain.href = contacts[mainContact].url;
          $aLinkButtons.append($aLinkContactMain);
          $aButtonsBox.append($aLinkButtons);
          // 购买同款按钮右侧其它联系方式
          for(let key in contacts){
            if(key!='main' && key!='animatedType' && key!=contacts['main']){
              let icon = contacts[key].icon;
              let $aLinkContact = document.createElement('a');
              $aLinkContact.setAttribute('class', 'contact-btn ui circular '+ icon +' mini icon button');
              $aLinkContact.setAttribute('target', '_blank');
              $aLinkContact.setAttribute('style', 'margin-left:.5em;');
              $aLinkContact.innerHTML = '<i class="'+ icon +' icon"></i>';
              $aLinkContact.href = contacts[key].url;
              $aButtonsBox.append($aLinkContact);
            }
          }
          $content.append($aButtonsBox);
        }
      });
    });
  }
  // ServerStatus主题
  function bindToggleViewClick(){
    let $toggleView = document.querySelector('aside.toolbox .toggleView')
    $toggleView && $toggleView.addEventListener('click', ()=>{
      setTimeout(function(){
        location.reload();
      }, 0);
    });
  }
  if(preferredTheme === 'server-status'){
    bindToggleViewClick();
    let $biThreeDots = document.querySelector('aside.toolbox .bi-three-dots');
    $biThreeDots && $biThreeDots.addEventListener('click', ()=>{
      bindToggleViewClick();
    });

    let $tables = document.querySelectorAll('.table.table-condensed');
    $tables.forEach(e=>{
      $tableTh = e.querySelector('.node-group-tag th');
      $list = e.querySelectorAll('tr.accordion-toggle');
      $tableTh && ($tableTh.innerText += '（'+ $list.length +'）');

      let $head = e.querySelector('table.table-condensed thead').lastChild;
      let $servers = e.querySelector('#servers');
      // 隐藏三列：系统、在线天数、负载
      $head.querySelector('th.os').style.display = 'none';
      $head.querySelector('th.uptime').style.display = 'none';
      $head.querySelector('th.load').style.display = 'none';
      // 添加三列
      let $expireTh = document.createElement('th');
      $expireTh.innerText = '到期 / 剩余价值';
      $expireTh.setAttribute('class', 'node-cell expire center');
      $head.insertBefore($expireTh, $head.childNodes[3]);

      let $buyTh = document.createElement('th');
      $buyTh.innerText = '购买同款';
      $buyTh.setAttribute('class', 'node-cell expire center');
      $head.append($buyTh);

      let $contactTh = document.createElement('th');
      $contactTh.innerText = '议价';
      $contactTh.setAttribute('class', 'node-cell expire center');
      $head.append($contactTh);

      $servers.querySelectorAll('tr.accordion-toggle').forEach(ee=>{
        ee.querySelector('td.os').style.display = 'none';
        ee.querySelector('td.uptime').style.display = 'none';
        ee.querySelector('td.load').style.display = 'none';

        let id = ee.getAttribute('id');
        id = id.replace('r', '');
        if(extraData[id]){
          let pid = extraData[id].pid;
          pid = parseInt(pid);
          let shop = extraData[id].shop;
          let price = extraData[id].price;
          let start = extraData[id].start;
          let expire = extraData[id].expire;
          let cycle = extraData[id].cycle;
          let autoPay = extraData[id].autoPay;
          let cycleName = cycleNames[cycle];
          let cycleValue = cycleValues[cycleName];
          let nowTime = parseInt(new Date().getTime() / 1000);
          let beginTime = parseInt(new Date(start).getTime() / 1000);
          if(autoPay && autoPay=='是'){
            let beginDate = new Date(start);
            let nowDate = new Date();
            let mSteps = {
              year: 12,
              half: 6,
              quarterly: 3,
              month: 1,
            }
            expire = beginDate.setMonth(beginDate.getMonth() + mSteps[cycleName]);
            expire = new Date(expire);
            while(expire.getTime() < nowDate.getTime()){
              expire = expire.setMonth(expire.getMonth() + mSteps[cycleName]);
              expire = new Date(expire);
            }
            expire = expire.toLocaleDateString();
          }
          let endTime = parseInt(new Date(expire).getTime() / 1000);

          if(expire || price){
            // 到期时间、剩余价值列
            let $expireTd = document.createElement('td');
            $expireTd.setAttribute('class', 'node-cell expire');
            let aTime = (nowTime-beginTime);
            let bTime = (endTime-beginTime);
            let cTime = parseInt(aTime / bTime * 100);
            let progressType = 'danger';
            if(expire === '∞'){
              progressType = 'warning';
            }

            let priceValue = price.replace(/[$￥P€]/g, '');
            let priceUnit = price.match(/[$￥P€]/g)[0];
            let remainingDays = Math.floor((endTime - nowTime) / (24 * 60 * 60));
            let remainingPrice = parseFloat(priceValue) / cycleValue  * remainingDays;
            if(!remainingPrice){
              remainingPrice = 0;
            }
            remainingPrice = remainingPrice.toFixed(2);
            $expireTd.innerHTML = '<div class="progress progress-expire"><div class="progress-bar progress-bar-'+ progressType +' progress-bar-striped active" style="width: '+ cTime +'%;padding-right:5px;background-image: linear-gradient(45deg, rgba(255, 255, 255, .15) 25%, transparent 25%, transparent 50%, rgba(255, 255, 255, .15) 50%, rgba(255, 255, 255, .15) 75%, transparent 75%, transparent);"><small class="progress" style="white-space: nowrap;background-color: transparent !important;background-image: unset;">'+ expire +' / '+ priceUnit + remainingPrice +'</small></div></div>';
            ee.insertBefore($expireTd, ee.childNodes[3]);
          }
          // 购买同款列
          let $buyTd = document.createElement('td');
          $buyTd.setAttribute('class', 'node-cell buy');
          $buyTd.setAttribute('style', 'text-align:center;');
          let $buyTdBtn = document.createElement('div');
          $buyTdBtn.setAttribute('class', 'ui left labeled button');
          let $buyTdBtnLabel = document.createElement('div');
          $buyTdBtnLabel.setAttribute('class', 'ui basic label mini');
          $buyTdBtnLabel.setAttribute('style', 'min-height: 20px;padding:0 .5em;height: 20px;font-weight:normal;line-height: 20px;font-size:.78571429rem;');
          $buyTdBtnLabel.innerHTML = price +' / '+ cycle;
          $buyTdBtn.append($buyTdBtnLabel);
          let $buyTdBtnLabelIcon = document.createElement('a');
          $buyTdBtnLabelIcon.setAttribute('class', 'ui icon button mini green');
          $buyTdBtnLabelIcon.setAttribute('style', 'min-height: 20px;padding:0 .5em;height: 20px;line-height: 20px;');
          $buyTdBtnLabelIcon.setAttribute('target', shop ? '_blank' : '');
          $buyTdBtnLabelIcon.addEventListener('click', (e)=>{e.stopPropagation()});
          $buyTdBtnLabelIcon.innerHTML = '<i class="shopping cart icon"></i>';
          $buyTdBtnLabelIcon.href = shop ? affLinks[shop] : 'javascript:void(0);';
          if(pid){
            $buyTdBtnLabelIcon.href += '&pid='+ pid;
          }
          $buyTdBtn.append($buyTdBtnLabelIcon);
          $buyTd.append($buyTdBtn);
          ee.append($buyTd);
          // 联系方式列
          let $contactTd = document.createElement('td');
          $contactTd.setAttribute('class', 'node-cell contact');
          $contactTd.setAttribute('style', 'text-align:center;white-space:nowrap;');
          for(let key in contacts){
            if(key!='main' && key!='animatedType'){
              let $contactTdContactBtn = document.createElement('a');
              let contactIcon = contacts[key].icon;
              $contactTdContactBtn.setAttribute('class', 'ui circular '+ contactIcon +' icon button mini blue');
              $contactTdContactBtn.setAttribute('style', 'min-height: 20px;padding:0 .5em;height: 20px;line-height: 20px;');
              $contactTdContactBtn.setAttribute('target', '_blank');
              $contactTdContactBtn.addEventListener('click', (e)=>{e.stopPropagation()});
              $contactTdContactBtn.innerHTML = '<i class="'+ contactIcon +' icon"></i>';
              $contactTdContactBtn.href = contacts[key].url;
              $contactTd.append($contactTdContactBtn);
            }
          }
          ee.append($contactTd);
        } else {
          // 无附加信息时显示占位符
          let $expireTd = document.createElement('td');
          $expireTd.setAttribute('class', 'node-cell expire');
          $expireTd.setAttribute('style', 'text-align:center;');
          $expireTd.innerHTML = '-';
          ee.insertBefore($expireTd, ee.childNodes[3]);
          let $buyTd = document.createElement('td');
          $buyTd.setAttribute('class', 'node-cell buy');
          $buyTd.setAttribute('style', 'text-align:center;');
          $buyTd.innerHTML = '-';
          ee.append($buyTd);
          let $contactTd = document.createElement('td');
          $contactTd.setAttribute('class', 'node-cell contact');
          $contactTd.setAttribute('style', 'text-align:center;');
          $contactTd.innerHTML = '-';
          ee.append($contactTd);
        }
      });
    });
  }
}
</script>
