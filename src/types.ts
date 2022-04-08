enum WXScene {
  WXSceneSession = 0 /**< 聊天界面    */,
  WXSceneTimeline = 1 /**< 朋友圈     */,
  WXSceneFavorite = 2 /**< 收藏       */,
  WXSceneSpecifiedSession = 3 /**< 指定联系人  */,
}
export interface AuthResponse {
  errCode?: number;
  errStr?: string;
  openId?: string;
  code?: string;
  url?: string;
  lang?: string;
  country?: string;
}
export interface WeChatReq {
  type?: string;
  errStr?: string;
  extMsg?: string;
  country?: string;
  state?: string;
  returnKey?: string;
}
export interface WeChatResp {
  type?: string;
  errStr?: string;
  extMsg?: string;
  country?: string;
  state?: string;
  returnKey?: string;
}
export interface ShareMetadata {
  type:
    | 'news'
    | 'text'
    | 'imageUrl'
    | 'imageFile'
    | 'imageResource'
    | 'video'
    | 'audio'
    | 'file';
  thumbImage?: string;
  description?: string;
  webpageUrl?: string;
  imageUrl?: string;
  videoUrl?: string;
  musicUrl?: string;
  filePath?: string;
  fileExtension?: string;
}
export interface ShareTextMetadata {
  text: string;
  scene?: WXScene;
}
export interface ShareImageMetadata {
  imageUrl: string;
  scene?: WXScene;
}
export interface ShareMusicMetadata {
  musicUrl: string;
  musicLowBandUrl?: string;
  musicDataUrl?: string;
  musicLowBandDataUrl?: string;
  title?: string;
  description?: string;
  thumbImageUrl?: string;
  scene?: WXScene;
}
export interface ShareVideoMetadata {
  videoUrl: string;
  videoLowBandUrl?: string;
  title?: string;
  description?: string;
  thumbImageUrl?: string;
  scene?: WXScene;
}
export interface ShareWebpageMetadata {
  webpageUrl: string;
  title?: string;
  description?: string;
  thumbImageUrl?: string;
  scene?: WXScene;
}
export interface ShareMiniProgramMetadata {
  webpageUrl: string;
  userName: string;
  path?: string;
  hdImageUrl?: string;
  withShareTicket?: string;
  miniProgramType?: number;
  title?: string;
  description?: string;
  thumbImageUrl?: string;
  scene?: WXScene;
}
export interface LaunchMiniProgramMetadata {
  userName: string;
  //0-正式版 1-开发版 2-体验版
  miniProgramType?: 0 | 1 | 2;
  path?: string;
}
export interface LaunchCustomerServiceMetadata {
  url: string;
  corpid: string;
}
export interface ShareFileMetadata {
  url: string;
  title?: string;
  ext?: string;
  scene?: WXScene;
}

export interface SubscribeMessageMetadata {
  scene?: WXScene;
  templateId: string;
  reserved?: string;
}
export interface PaymentLoad {
  partnerId: string;
  prepayId: string;
  nonceStr: string;
  timeStamp: string;
  package: string;
  sign: string;
}
export interface ChooseInvoice {
  signType?: string;
  nonceStr?: string;
  timeStamp?: number;
  cardSign?: string;
}

export interface Invoice {
  appId: string;
  cardId: string;
  encryptCode: string;
}
