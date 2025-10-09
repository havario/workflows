<script>
window.onload = function(){
  const storagePreKey = 'nzVpsChuChuangData.';
  const storageSet = function(key, value){
    key = `${storagePreKey}${key}`;
    localStorage.setItem(key, JSON.stringify(value));
  }
  const storageGet = function(key, defaultValue){
    key = `${storagePreKey}${key}`;
    return JSON.parse(localStorage.getItem(key)) || defaultValue;
  }
  const extraDataKeyName = {
    shop:"商家名称",
    pid: '产品ID',
    price:"购买价格",
    cycle: "付款周期",
    start: "购买日期",
    expire: "过期时间",
    autoPay: '自动续费',
  }
  const cycleOptions = [
    '年付',
    '半年付',
    '季付',
    '月付',
    '年',
    '半',
    '季',
    '月',
    'Year',
    'Half',
    'Quarterly',
    'Month',
    'Y',
    'H',
    'Q',
    'M',
    'year',
    'half',
    'quarterly',
    'month',
  ];
  const autoPayOptions = [
    '否',
    '是'
  ];
  let timmer = null;
  let changer = false;
  const pathname = location.pathname;
  const $footer = document.querySelector('.footer');
  if(!$footer || $footer.innerText.indexOf('Powered by 哪吒监控')==-1) return false;
  let raw = storageGet('raw', '');
  let affLinks = storageGet('affLinks', null);
  let extra = storageGet('extra', null);
  let isFirst = false;
  if(affLinks == null && extra== null){
    isFirst = true;
  }
  if(pathname === '/setting'){
    const $settingForm = document.forms.settingForm;
    let settingData = new FormData($settingForm);
    settingData = new URLSearchParams(settingData).toString();
    storageSet('raw', settingData);
    const CustomCode = document.querySelector('textarea[name=CustomCode]').value;
    let CustomCodeValueAffLinks =CustomCode.match(/(?<=affLinks = )[\s\S]+(?=\n([\s\t]+)?const contacts)/g);
    let CustomCodeValueExtra =CustomCode.match(/(?<=extraData = )[\s\S]+(?=\n([\s\t]+)?const cycleNames)/g);
    if(!CustomCodeValueAffLinks || !CustomCodeValueExtra){
      $.suiAlert({
          title: '',
          description: '请检查是否已经添加《哪吒面板VPS橱窗脚本》，脚本可去：https://www.bmqy.net/2665.html，获取',
          type: 'error',
          time: '3',
          position: 'top-center',
      });
      return false;
    }
    CustomCodeValueAffLinks = CustomCodeValueAffLinks ? CustomCodeValueAffLinks[0] : '{}';
    CustomCodeValueAffLinks = CustomCodeValueAffLinks.replace(/([0-9a-zA-Z]+):\s?'/g, '"$1":"').replace(/'/g, '"').replace(/[\r\n]+/g, '').replace(/,}/g, '}');
    affLinks = JSON.parse(CustomCodeValueAffLinks);
    storageSet('affLinks', affLinks);
    CustomCodeValueExtra = CustomCodeValueExtra ? CustomCodeValueExtra[0] : '{}';
    CustomCodeValueExtra = CustomCodeValueExtra.replace(/([0-9a-zA-Z]+):/g, '"$1":').replace(/},\n}/g, '}\n}').replace(/'/g, '"').replace(/[\r\n]+/g, '').replace(/,}/g, '}');
    extra = JSON.parse(CustomCodeValueExtra);
    storageSet('extra', extra);
    if(isFirst){
      $.suiAlert({
          title: '',
          description: 'VPS橱窗后台脚本数据获取成功，可以正常使用了。',
          type: 'success',
          time: '3',
          position: 'top-center',
      });
    } else {
      $.suiAlert({
          title: '',
          description: 'VPS橱窗后台脚本已重新获取数据。',
          type: 'success',
          time: '3',
          position: 'top-center',
      });
    }
  } else {
    if(pathname !='/' && pathname !='/login' && (affLinks == null || extra == null)){
      $.suiAlert({
          title: '',
          description: '请先进入【设置】页面获取脚本所需数据！！！',
          type: 'warning',
          time: '3',
          position: 'top-center',
      });
      return false;
    }
    if(pathname === '/server'){
      createShopFormModal(affLinks);
      const $table = document.querySelector('table.table');
      const $tableTr = $table.querySelectorAll('tbody tr');
      $tableTr.forEach(e=>{
        let $tds = e.querySelectorAll('td');
        let id = $tds[1].innerText;
        id = id.replace(/\(\d+\)/g, '');
        let $nameTd = $tds[2];
        let $extraDataBox = document.createElement('div');
        $extraDataBox.id = id;
        $extraDataBox.setAttribute('class', 'extra-box');
        $extraDataBox.setAttribute('style', 'margin-top:10px;');
        for(let key in extraDataKeyName){
          let extraData = extra[id];
          let $inputLabel = document.createElement('div');
          $inputLabel.setAttribute('style', 'white-space: nowrap;padding-bottom:3px;');
          let requiredTag = '';
          if(['price', 'cycle', 'start'].indexOf(key) > -1){
            requiredTag = '*';
          }
          $inputLabel.innerHTML = '<span style="display:inline-block;width:70px;">'+ requiredTag + extraDataKeyName[key] +'：</span>';
          let $input = document.createElement('input');
          if(key === 'pid'){
            $input.placeholder = '商家所售产品ID';
          } else if(['start', 'expire'].indexOf(key) > -1){
            $input.placeholder = '月/日/年';
          } else if(key === 'price'){
            $input.placeholder = '支持：$、￥、€、P';
          }
          if(['shop', 'cycle', 'autoPay'].indexOf(key) > -1){
            $input = document.createElement('select');
            if(key === 'shop'){
              $input.options.add(new Option('请选择', ''));
              for(let key in affLinks){
                $input.options.add(new Option(key, key));
              }
            }
            if(key === 'cycle'){
              for(let key in cycleOptions){
                $input.options.add(new Option(cycleOptions[key], cycleOptions[key]));
              }
            }
            if(key === 'autoPay'){
              for(let key in autoPayOptions){
                $input.options.add(new Option(autoPayOptions[key], autoPayOptions[key]));
              }
            }
          }
          $input.name = key;
          if(extraData){
            $input.value = extraData[key] ? extraData[key] : '';
          }
          $input.addEventListener('change', ()=>{
            changer = true;
            if(timmer) return false;
            console.log('1s 后提交');
            timmer = setTimeout(function(){
                updateExtraData();
            }, 1500);
          });
          $input.addEventListener('focus', ()=>{
            if(timmer){
              console.log('终断提交');
              clearTimeout(timmer);
              timmer = null;
            }
          });
          $input.addEventListener('blur', ()=>{
            if(timmer) return false;
            if(changer){
              console.log('1s 后提交');
              timmer = setTimeout(function(){
                  updateExtraData();
              }, 1500);
            }
          });
          $inputLabel.append($input);
          if(key === 'shop'){
            let $addShopBtn = document.createElement('button');
            $addShopBtn.title = '管理商家信息';
            $addShopBtn.setAttribute('class', 'ui icon button mini');
            $addShopBtn.setAttribute('style', 'margin-left:5px;');
            $addShopBtn.innerHTML = '<i class="icon setting"></i>';
            $addShopBtn.addEventListener('click', managerShoopFormModal);
            $inputLabel.append($addShopBtn);
          }
          $extraDataBox.append($inputLabel);
        }
        $nameTd.append($extraDataBox);
      })
    }
  }

  function updateExtraData(){
    let paramsRaw = new URLSearchParams(raw);
    let customCodeOld = paramsRaw.get('CustomCode');
    let $extraBox = document.querySelectorAll('table.table .extra-box');
    let extraNew = {};
    $extraBox.forEach(e=>{
        let shop = e.querySelector('select[name=shop]').value,
            pid = e.querySelector('input[name=pid]').value,
            price = e.querySelector('input[name=price]').value,
            cycle = e.querySelector('select[name=cycle]').value,
            start = e.querySelector('input[name=start]').value,
            expire = e.querySelector('input[name=expire]').value,
            autoPay = e.querySelector('select[name=autoPay]').value;
        if(price && cycle && start){
            extraNew[e.id] = {
                shop: shop,
                pid: pid,
                price: price,
                cycle: cycle,
                start: start,
                expire: expire,
                autoPay: autoPay,
            }
        }
    });
    storageSet('extra', extraNew);
    let customCodeNew = customCodeOld.replace(/(?<=extraData = )[\s\S]+(?=\n[\s\t]*const cycleNames)/g, JSON.stringify(extraNew));
    paramsRaw.set('CustomCode', customCodeNew);
    $.post('/api/setting', paramsRaw.toString()).then(res=>{
      if(res.code == 200){
        $.suiAlert({
            title: '',
            description: 'VPS橱窗前台脚本更新成功。',
            type: 'success',
            time: '3',
            position: 'top-center',
        });
      } else {
        $.suiAlert({
            title: '',
            description: responses.responseText,
            type: 'error',
            time: '3',
            position: 'top-center',
        });
      }
    }).catch(err=>{
      $.suiAlert({
          title: '',
          description: JSON.stringify(err),
          type: 'error',
          time: '3',
          position: 'top-center',
      });
    }).always(()=>{
      clearTimeout(timmer);
      timmer = null;
      changer = false;
    })
  }

  function managerShoopFormModal(){
    showOnSubmitFormModal(".shopForm.modal", "#shopForm", "/api/setting", getShopData);
  }

  function getShopData(){
    let paramsRaw = new URLSearchParams(raw);
    let customCodeOld = paramsRaw.get('CustomCode');
    let affLinks = storageGet('affLinks', null);
    let customCodeNew = customCodeOld.replace(/(?<=affLinks = )[\s\S]+(?=\n[\s\t]*const contacts)/g, JSON.stringify(affLinks));
    paramsRaw.set('CustomCode', customCodeNew);
    return paramsRaw.toString();
  }

  function updateShopData(){
    let $shopForm = document.querySelector('#shopForm');
    let data = {};
    let emptyCount = 0;
    for(let i=0; i<$shopForm.elements.length; i+=2){
      let $name = $shopForm.elements[i];
      let $url = $shopForm.elements[i+1];
      if($name.value && $url.value){
        data[$name.value] = $url.value;
        storageSet('affLinks', data);
        if(i == $shopForm.elements.length-2){
          createShopFormModal(data);
        }
      } else {
        emptyCount += 1;
      }
    }
    if(emptyCount > 1){
      createShopFormModal(data);
    }
  }

  function createInput(name, value){
    let $input = document.createElement('input');
    $input.type = 'text';
    $input.name = name;
    $input.setAttribute('value', value || '');
    $input.placeholder = name==='name' ? '名称' : '邀请链接';
    $input.addEventListener('blur', updateShopData);
    return $input;
  }
  function createShopFormModal(affLinks){
    let $shopFormModal = document.querySelector('#shopFormModal');
    let isFirst = true;
    if(!$shopFormModal){
      $shopFormModal = document.createElement('div');
      $shopFormModal.id = 'shopFormModal';
      $shopFormModal.setAttribute('class', 'ui tiny shopForm modal transition hidden');
    } else {
      isFirst = false;
      $shopFormModal.innerHTML = '';
    }
    let $shopForm = document.createElement('form');
    $shopForm.id = 'shopForm';
    $shopForm.setAttribute('class', 'ui form');
    for(let key in affLinks){
      let $shopFormField = document.createElement('div');
      let $shopFormGrid = document.createElement('div');
      $shopFormGrid.setAttribute('class', 'ui grid');
      let $shopFormGridItem = document.createElement('div');
      $shopFormGridItem.setAttribute('class', 'four wide column');
      $shopFormGridItem.append(createInput('name', key));
      $shopFormGrid.append($shopFormGridItem);
      $shopFormGridItem = document.createElement('div');
      $shopFormGridItem.setAttribute('class', 'twelve wide column');
      $shopFormGridItem.append(createInput('url', affLinks[key]));
      $shopFormGrid.append($shopFormGridItem);
      $shopFormField.append($shopFormGrid);
      $shopForm.append($shopFormField);
    }
    let $shopFormField = document.createElement('div');
    let $shopFormGrid = document.createElement('div');
    $shopFormGrid.setAttribute('class', 'ui grid');
    let $shopFormGridItem = document.createElement('div');
    $shopFormGridItem = document.createElement('div');
    $shopFormGridItem.setAttribute('class', 'four wide column');
    $shopFormGridItem.append(createInput('name', ''));
    $shopFormGrid.append($shopFormGridItem);
    $shopFormGridItem = document.createElement('div');
    $shopFormGridItem.setAttribute('class', 'twelve wide column');
    $shopFormGridItem.append(createInput('url', ''));
    $shopFormGrid.append($shopFormGridItem);
    $shopFormField.append($shopFormGrid);
    $shopForm.append($shopFormField);

    let $shopFormModalHead = document.createElement('div');
    $shopFormModalHead.setAttribute('class', 'header');
    $shopFormModalHead.innerHTML = 'VPS橱窗商家信息管理';
    $shopFormModal.append($shopFormModalHead);
    let $shopFormModalContent = document.createElement('div');
    $shopFormModalContent.setAttribute('class', 'content');
    $shopFormModalContent.append($shopForm);
    $shopFormModal.append($shopFormModalContent);
    let $shopFormModalActions = document.createElement('div');
    $shopFormModalActions.setAttribute('class', 'actions');
    let $shopFormModalActionsCancelBtn = document.createElement('div');
    $shopFormModalActionsCancelBtn.setAttribute('class', 'ui negative button');
    $shopFormModalActionsCancelBtn.innerHTML = '取消';
    $shopFormModalActions.append($shopFormModalActionsCancelBtn);
    let $shopFormModalActionsConfirmBtn = document.createElement('div');
    $shopFormModalActionsConfirmBtn.setAttribute('class', 'ui positive nezha-primary-btn right labeled icon button vps-window-btn');
    $shopFormModalActionsConfirmBtn.innerHTML = '确认<i class="checkmark icon"></i>';
    $shopFormModalActions.append($shopFormModalActionsConfirmBtn);
    $shopFormModal.append($shopFormModalActions);
    isFirst && document.body.append($shopFormModal);
  }

  function showOnSubmitFormModal(modelSelector, formID, URL, getData) {
    $(modelSelector)
    .modal({
      closable: true,
      onApprove: function () {
        let success = false;
        const btn = $(modelSelector + " .vps-window-btn.button");
        const form = $(modelSelector + " form");
        if (btn.hasClass("loading")) {
          return success;
        }
        form.children(".message").remove();
        btn.toggleClass("loading");
        const data = getData
          ? getData()
          : $(formID)
            .serializeArray()
            .reduce(function (obj, item) {
              // ID 类的数据
              if (item.name === "pid") {
                obj[item.name] = parseInt(item.value);
              } else {
                obj[item.name] = item.value;
              }
              return obj;
            }, {});
        $.post(URL, data)
          .done(function (resp) {
            if (resp.code == 200) {
              window.location.reload()
            } else {
              form.append(
                `<div class="ui negative message"><div class="header">操作失败</div><p>` +
                resp.message +
                `</p></div>`
              );
            }
          })
          .fail(function (err) {
            form.append(
              `<div class="ui negative message"><div class="header">网络错误</div><p>` +
              err.responseText +
              `</p></div>`
            );
          })
          .always(function () {
            btn.toggleClass("loading");
          });
        return success;
      },
    })
    .modal("show");
  }
}
</script>
