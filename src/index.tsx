import { NativeModules, Platform } from 'react-native';
import type {
  AuthResponse,
  ChooseInvoice,
  Invoice,
  LaunchCustomerServiceMetadata,
  LaunchMiniProgramMetadata,
  PaymentLoad,
  ShareFileMetadata,
  ShareImageMetadata,
  ShareMiniProgramMetadata,
  ShareMusicMetadata,
  ShareTextMetadata,
  ShareVideoMetadata,
  ShareWebpageMetadata,
  SubscribeMessageMetadata,
} from './types';
import { EventEmitter, DeviceEventEmitter } from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-wechat-api' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo managed workflow\n';

const emitter = new EventEmitter();

DeviceEventEmitter.addListener('WeChat_Resp', (resp) => {
  emitter.emit(resp.type, resp);
});

DeviceEventEmitter.addListener('WeChat_Req', (resp) => {
  emitter.emit(resp.type, resp);
});

const WechatApi = NativeModules.WechatApi
  ? NativeModules.WechatApi
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );
/**
 * 是否已经注册过微信
 */
let isAppRegistered = false;
/**
 * 注册微信
 * @param appId
 * @param universalLink
 */
export function registerApp(
  appId: string,
  universalLink?: string
): Promise<boolean> {
  return new Promise<boolean>((resolve, reject) => {
    WechatApi.registerApp(appId, universalLink)
      .then((res: boolean) => {
        isAppRegistered = true;
        resolve(res);
      })
      .catch((e: any) => {
        reject(e);
      });
  });
}

/**
 * 微信是否安装
 */
export function isWXAppInstalled(): Promise<boolean> {
  return new Promise<boolean>((resolve, reject) => {
    if (isAppRegistered) {
      WechatApi.isWXAppInstalled().then((res: boolean) => {
        resolve(res);
      });
    } else {
      reject(new Error('registerApp required'));
    }
  });
}

/**
 * 微信支持api
 */
export function isWXAppSupportApi(): Promise<boolean> {
  return new Promise<boolean>((resolve, reject) => {
    if (isAppRegistered) {
      WechatApi.isWXAppSupportApi().then((res: boolean) => {
        resolve(res);
      });
    } else {
      reject(new Error('registerApp required'));
    }
  });
}

/**
 * 获取微信的api版本
 */
export function getApiVersion(): Promise<string> {
  return new Promise<string>((resolve, reject) => {
    if (isAppRegistered) {
      WechatApi.getApiVersion().then((res: string) => {
        resolve(res);
      });
    } else {
      reject(new Error('registerApp required'));
    }
  });
}

/**
 * 打开微信
 */
export function openWXApp(): Promise<boolean> {
  return new Promise<boolean>((resolve, reject) => {
    if (isAppRegistered) {
      WechatApi.openWXApp().then((res: boolean) => {
        resolve(res);
      });
    } else {
      reject(new Error('registerApp required'));
    }
  });
}

export function sendAuthRequest(
  scopes: string | string[],
  state?: string
): Promise<AuthResponse> {
  return new Promise<AuthResponse>((resolve, reject) => {
    if (isAppRegistered) {
      WechatApi.sendAuthRequest(scopes, state).then();
    } else {
      reject(new Error('registerApp required'));
    }
    emitter.once(
      'SendAuth.Resp',
      (resp) => {
        if (resp.errCode === 0) {
          resolve(resp);
        } else {
          reject(new WechatError(resp));
        }
      },
      null
    );
  });
}
export function shareText(
  message: ShareTextMetadata
): Promise<{ errCode?: number; errStr?: string }> {
  if (message.scene === undefined) {
    message.scene = 0;
  }
  return new Promise<{ errCode?: number; errStr?: string }>(
    (resolve, reject) => {
      if (isAppRegistered) {
        WechatApi.shareText(message).then();
      } else {
        reject(new Error('registerApp required'));
      }
      emitter.once(
        'SendMessageToWX.Resp',
        (resp) => {
          if (resp.errCode === 0) {
            resolve(resp);
          } else {
            reject(new WechatError(resp));
          }
        },
        null
      );
    }
  );
}
export function shareImage(
  message: ShareImageMetadata
): Promise<{ errCode?: number; errStr?: string }> {
  if (message.scene === undefined) {
    message.scene = 0;
  }
  return new Promise<{ errCode?: number; errStr?: string }>(
    (resolve, reject) => {
      if (isAppRegistered) {
        WechatApi.shareImage(message).then();
      } else {
        reject(new Error('registerApp required'));
      }
      emitter.once(
        'SendMessageToWX.Resp',
        (resp) => {
          if (resp.errCode === 0) {
            resolve(resp);
          } else {
            reject(new WechatError(resp));
          }
        },
        null
      );
    }
  );
}
export function shareLocalImage(
  message: ShareImageMetadata
): Promise<{ errCode?: number; errStr?: string }> {
  if (message.scene === undefined) {
    message.scene = 0;
  }
  return new Promise<{ errCode?: number; errStr?: string }>(
    (resolve, reject) => {
      if (isAppRegistered) {
        WechatApi.shareLocalImage(message).then();
      } else {
        reject(new Error('registerApp required'));
      }
      emitter.once(
        'SendMessageToWX.Resp',
        (resp) => {
          if (resp.errCode === 0) {
            resolve(resp);
          } else {
            reject(new WechatError(resp));
          }
        },
        null
      );
    }
  );
}
export function shareMusic(
  message: ShareMusicMetadata
): Promise<{ errCode?: number; errStr?: string }> {
  if (message.scene === undefined) {
    message.scene = 0;
  }
  return new Promise<{ errCode?: number; errStr?: string }>(
    (resolve, reject) => {
      if (isAppRegistered) {
        WechatApi.shareMusic(message).then();
      } else {
        reject(new Error('registerApp required'));
      }
      emitter.once(
        'SendMessageToWX.Resp',
        (resp) => {
          if (resp.errCode === 0) {
            resolve(resp);
          } else {
            reject(new WechatError(resp));
          }
        },
        null
      );
    }
  );
}
export function shareVideo(
  message: ShareVideoMetadata
): Promise<{ errCode?: number; errStr?: string }> {
  if (message.scene === undefined) {
    message.scene = 0;
  }
  return new Promise<{ errCode?: number; errStr?: string }>(
    (resolve, reject) => {
      if (isAppRegistered) {
        WechatApi.shareVideo(message).then();
      } else {
        reject(new Error('registerApp required'));
      }
      emitter.once(
        'SendMessageToWX.Resp',
        (resp) => {
          if (resp.errCode === 0) {
            resolve(resp);
          } else {
            reject(new WechatError(resp));
          }
        },
        null
      );
    }
  );
}
export function shareWebpage(
  message: ShareWebpageMetadata
): Promise<{ errCode?: number; errStr?: string }> {
  if (message.scene === undefined) {
    message.scene = 0;
  }
  return new Promise<{ errCode?: number; errStr?: string }>(
    (resolve, reject) => {
      if (isAppRegistered) {
        WechatApi.shareWebpage(message).then();
      } else {
        reject(new Error('registerApp required'));
      }
      emitter.once(
        'SendMessageToWX.Resp',
        (resp) => {
          if (resp.errCode === 0) {
            resolve(resp);
          } else {
            reject(new WechatError(resp));
          }
        },
        null
      );
    }
  );
}
export function shareMiniProgram(
  message: ShareMiniProgramMetadata
): Promise<{ errCode?: number; errStr?: string }> {
  if (message.scene === undefined) {
    message.scene = 0;
  }
  if (message.miniProgramType === undefined) {
    message.miniProgramType = 0;
  }
  return new Promise<{ errCode?: number; errStr?: string }>(
    (resolve, reject) => {
      if (isAppRegistered) {
        WechatApi.shareMiniProgram(message).then();
      } else {
        reject(new Error('registerApp required'));
      }
      emitter.once(
        'SendMessageToWX.Resp',
        (resp) => {
          if (resp.errCode === 0) {
            resolve(resp);
          } else {
            reject(new WechatError(resp));
          }
        },
        null
      );
    }
  );
}
export function shareFile(
  message: ShareFileMetadata
): Promise<{ errCode?: number; errStr?: string }> {
  if (message.scene === undefined) {
    message.scene = 0;
  }
  return new Promise<{ errCode?: number; errStr?: string }>(
    (resolve, reject) => {
      if (isAppRegistered) {
        WechatApi.shareFile(message).then();
      } else {
        reject(new Error('registerApp required'));
      }
      emitter.once(
        'SendMessageToWX.Resp',
        (resp) => {
          if (resp.errCode === 0) {
            resolve(resp);
          } else {
            reject(new WechatError(resp));
          }
        },
        null
      );
    }
  );
}
export function launchCustomerService({
  corpid,
  url,
}: LaunchCustomerServiceMetadata): Promise<{
  errCode?: number;
  errStr?: string;
}> {
  return new Promise<{ errCode?: number; errStr?: string }>(
    (resolve, reject) => {
      if (isAppRegistered) {
        WechatApi.launchCustomerService({ corpid, url }).then();
      } else {
        reject(new Error('registerApp required'));
      }
      emitter.once(
        'WXOpenCustomerServiceReq.Resp',
        (resp) => {
          if (resp.errCode === 0) {
            resolve(resp);
          } else {
            reject(new WechatError(resp));
          }
        },
        null
      );
    }
  );
}
export function launchMiniProgram({
  userName,
  miniProgramType,
  path = '',
}: LaunchMiniProgramMetadata): Promise<{ errCode?: number; errStr?: string }> {
  if (miniProgramType === undefined) {
    miniProgramType = 0;
  }
  return new Promise<{ errCode?: number; errStr?: string }>(
    (resolve, reject) => {
      if (isAppRegistered) {
        WechatApi.launchMiniProgram({ userName, miniProgramType, path }).then();
      } else {
        reject(new Error('registerApp required'));
      }
      emitter.once(
        'WXLaunchMiniProgramReq.Resp',
        (resp) => {
          if (resp.errCode === 0) {
            resolve(resp);
          } else {
            reject(new WechatError(resp));
          }
        },
        null
      );
    }
  );
}
export function subscribeMessage(
  message: SubscribeMessageMetadata
): Promise<{ errCode?: number; errStr?: string }> {
  if (message.scene === undefined) {
    message.scene = 0;
  }
  return new Promise<{ errCode?: number; errStr?: string }>(
    (resolve, reject) => {
      if (isAppRegistered) {
        WechatApi.subscribeMessage(message).then();
      } else {
        reject(new Error('registerApp required'));
      }
      emitter.once(
        'WXSubscribeMsgReq.Resp',
        (resp) => {
          if (resp.errCode === 0) {
            resolve(resp);
          } else {
            reject(new WechatError(resp));
          }
        },
        null
      );
    }
  );
}
export function chooseInvoice(
  message: ChooseInvoice
): Promise<{ errCode?: number; errStr?: string; cards: Invoice[] }> {
  return new Promise<{ errCode?: number; errStr?: string; cards: Invoice[] }>(
    (resolve, reject) => {
      if (isAppRegistered) {
        WechatApi.chooseInvoice(message).then();
      } else {
        reject(new Error('registerApp required'));
      }
      emitter.once(
        'WXChooseInvoiceResp.Resp',
        (resp) => {
          if (resp.errCode === 0) {
            if (Platform.OS === 'android') {
              const cardItemList = JSON.parse(resp.cardItemList);
              resp.cards = cardItemList
                ? cardItemList.map((item: any) => ({
                    cardId: item.card_id,
                    encryptCode: item.encrypt_code,
                  }))
                : [];
            }
            resolve(resp);
          } else {
            reject(new WechatError(resp));
          }
        },
        null
      );
    }
  );
}

export function pay(
  message: PaymentLoad
): Promise<{ errCode?: number; errStr?: string }> {
  function correct(actual: string, fixed: string) {
    // @ts-ignore
    if (!message[fixed] && message[actual]) {
      // @ts-ignore
      message[fixed] = message[actual];
      // @ts-ignore
      delete message[actual];
    }
  }
  correct('prepayid', 'prepayId');
  correct('noncestr', 'nonceStr');
  correct('partnerid', 'partnerId');
  correct('timestamp', 'timeStamp');
  // FIXME(94cstyles)
  // Android requires the type of the timeStamp field to be a string
  if (Platform.OS === 'android') message.timeStamp = String(message.timeStamp);

  return new Promise<{ errCode?: number; errStr?: string }>(
    (resolve, reject) => {
      if (isAppRegistered) {
        WechatApi.pay(message)
          .then()
          .catch((e: any) => {
            reject(e);
          });
      } else {
        reject(new Error('registerApp required'));
      }
      emitter.once(
        'PayReq.Resp',
        (resp) => {
          if (resp.errCode === 0) {
            resolve(resp);
          } else {
            reject(new WechatError(resp));
          }
        },
        null
      );
    }
  );
}
/**
 * promises will reject with this error when API call finish with an errCode other than zero.
 */
export class WechatError extends Error {
  name: string;
  code: number;
  constructor(resp: any) {
    const message = resp.errStr || resp.errCode.toString();
    super(message);
    this.name = 'WechatError';
    this.code = resp.errCode;
  }
}
