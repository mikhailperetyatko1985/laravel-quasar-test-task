import { Router } from 'vue-router';
import { Store } from 'pinia';

declare module '*.vue' {
  import type { DefineComponent } from 'vue'
  const component: DefineComponent<{}, {}, any>
  export default component
}

declare module 'quasar/wrappers' {
  import { App } from 'vue';
  
  export interface BootFileParams<TStore = Store> {
    app: App;
    router: Router;
    store: TStore;
  }

  export function boot<TStore = Store>(
    callback: (params: BootFileParams<TStore>) => void | Promise<void>
  ): (params: BootFileParams<TStore>) => void | Promise<void>;

  export function configure(callback: any): any;
  export function preFetch(callback: any): any;
  export function route(callback: any): any;
  export function store(callback: any): any;
  export function ssrMiddleware(callback: any): any;
  export function ssrProductionExport(callback: any): any;
  export function ssrCreate(callback: any): any;
  export function ssrListen(callback: any): any;
  export function ssrClose(callback: any): any;
  export function ssrServeStaticContent(callback: any): any;
  export function ssrRenderPreloadTag(callback: any): any;
  export function bexBackground(callback: any): any;
  export function bexContent(callback: any): any;
  export function bexDom(callback: any): any;
}

declare module '@vue/runtime-core' {
  export interface GlobalComponents {
    QAvatar: (typeof import('quasar'))['QAvatar'];
    QBadge: (typeof import('quasar'))['QBadge'];
    QBanner: (typeof import('quasar'))['QBanner'];
    QBar: (typeof import('quasar'))['QBar'];
    QBtn: (typeof import('quasar'))['QBtn'];
    QBtnDropdown: (typeof import('quasar'))['QBtnDropdown'];
    QBtnGroup: (typeof import('quasar'))['QBtnGroup'];
    QBtnToggle: (typeof import('quasar'))['QBtnToggle'];
    QCard: (typeof import('quasar'))['QCard'];
    QCardActions: (typeof import('quasar'))['QCardActions'];
    QCardSection: (typeof import('quasar'))['QCardSection'];
    QCheckbox: (typeof import('quasar'))['QCheckbox'];
    QChip: (typeof import('quasar'))['QChip'];
    QCircularProgress: (typeof import('quasar'))['QCircularProgress'];
    QDate: (typeof import('quasar'))['QDate'];
    QDialog: (typeof import('quasar'))['QDialog'];
    QDrawer: (typeof import('quasar'))['QDrawer'];
    QExpansionItem: (typeof import('quasar'))['QExpansionItem'];
    QFab: (typeof import('quasar'))['QFab'];
    QFabAction: (typeof import('quasar'))['QFabAction'];
    QField: (typeof import('quasar'))['QField'];
    QFile: (typeof import('quasar'))['QFile'];
    QFooter: (typeof import('quasar'))['QFooter'];
    QForm: (typeof import('quasar'))['QForm'];
    QHeader: (typeof import('quasar'))['QHeader'];
    QIcon: (typeof import('quasar'))['QIcon'];
    QImg: (typeof import('quasar'))['QImg'];
    QInfiniteScroll: (typeof import('quasar'))['QInfiniteScroll'];
    QInnerLoading: (typeof import('quasar'))['QInnerLoading'];
    QInput: (typeof import('quasar'))['QInput'];
    QIntersection: (typeof import('quasar'))['QIntersection'];
    QItem: (typeof import('quasar'))['QItem'];
    QItemLabel: (typeof import('quasar'))['QItemLabel'];
    QItemSection: (typeof import('quasar'))['QItemSection'];
    QKnob: (typeof import('quasar'))['QKnob'];
    QLayout: (typeof import('quasar'))['QLayout'];
    QLinearProgress: (typeof import('quasar'))['QLinearProgress'];
    QList: (typeof import('quasar'))['QList'];
    QMarkupTable: (typeof import('quasar'))['QMarkupTable'];
    QMenu: (typeof import('quasar'))['QMenu'];
    QOptionGroup: (typeof import('quasar'))['QOptionGroup'];
    QPage: (typeof import('quasar'))['QPage'];
    QPageContainer: (typeof import('quasar'))['QPageContainer'];
    QPageScroller: (typeof import('quasar'))['QPageScroller'];
    QPageSticky: (typeof import('quasar'))['QPageSticky'];
    QPagination: (typeof import('quasar'))['QPagination'];
    QParallax: (typeof import('quasar'))['QParallax'];
    QPopupEdit: (typeof import('quasar'))['QPopupEdit'];
    QPopupProxy: (typeof import('quasar'))['QPopupProxy'];
    QPullToRefresh: (typeof import('quasar'))['QPullToRefresh'];
    QRadio: (typeof import('quasar'))['QRadio'];
    QRange: (typeof import('quasar'))['QRange'];
    QRating: (typeof import('quasar'))['QRating'];
    QResizeObserver: (typeof import('quasar'))['QResizeObserver'];
    QResponsive: (typeof import('quasar'))['QResponsive'];
    QRouteTab: (typeof import('quasar'))['QRouteTab'];
    QScrollArea: (typeof import('quasar'))['QScrollArea'];
    QScrollObserver: (typeof import('quasar'))['QScrollObserver'];
    QSelect: (typeof import('quasar'))['QSelect'];
    QSeparator: (typeof import('quasar'))['QSeparator'];
    QSkeleton: (typeof import('quasar'))['QSkeleton'];
    QSlideItem: (typeof import('quasar'))['QSlideItem'];
    QSlideTransition: (typeof import('quasar'))['QSlideTransition'];
    QSlider: (typeof import('quasar'))['QSlider'];
    QSpace: (typeof import('quasar'))['QSpace'];
    QSpinner: (typeof import('quasar'))['QSpinner'];
    QSpinnerAudio: (typeof import('quasar'))['QSpinnerAudio'];
    QSpinnerBall: (typeof import('quasar'))['QSpinnerBall'];
    QSpinnerBars: (typeof import('quasar'))['QSpinnerBars'];
    QSpinnerBox: (typeof import('quasar'))['QSpinnerBox'];
    QSpinnerClock: (typeof import('quasar'))['QSpinnerClock'];
    QSpinnerComment: (typeof import('quasar'))['QSpinnerComment'];
    QSpinnerCube: (typeof import('quasar'))['QSpinnerCube'];
    QSpinnerDots: (typeof import('quasar'))['QSpinnerDots'];
    QSpinnerFacebook: (typeof import('quasar'))['QSpinnerFacebook'];
    QSpinnerGears: (typeof import('quasar'))['QSpinnerGears'];
    QSpinnerGrid: (typeof import('quasar'))['QSpinnerGrid'];
    QSpinnerHearts: (typeof import('quasar'))['QSpinnerHearts'];
    QSpinnerHourglass: (typeof import('quasar'))['QSpinnerHourglass'];
    QSpinnerInfinity: (typeof import('quasar'))['QSpinnerInfinity'];
    QSpinnerIos: (typeof import('quasar'))['QSpinnerIos'];
    QSpinnerOrbit: (typeof import('quasar'))['QSpinnerOrbit'];
    QSpinnerOval: (typeof import('quasar'))['QSpinnerOval'];
    QSpinnerPie: (typeof import('quasar'))['QSpinnerPie'];
    QSpinnerPuff: (typeof import('quasar'))['QSpinnerPuff'];
    QSpinnerRadio: (typeof import('quasar'))['QSpinnerRadio'];
    QSpinnerRings: (typeof import('quasar'))['QSpinnerRings'];
    QSpinnerTail: (typeof import('quasar'))['QSpinnerTail'];
    QSplitter: (typeof import('quasar'))['QSplitter'];
    QStep: (typeof import('quasar'))['QStep'];
    QStepper: (typeof import('quasar'))['QStepper'];
    QStepperNavigation: (typeof import('quasar'))['QStepperNavigation'];
    QTab: (typeof import('quasar'))['QTab'];
    QTabPanel: (typeof import('quasar'))['QTabPanel'];
    QTabPanels: (typeof import('quasar'))['QTabPanels'];
    QTable: (typeof import('quasar'))['QTable'];
    QTabs: (typeof import('quasar'))['QTabs'];
    QTd: (typeof import('quasar'))['QTd'];
    QTh: (typeof import('quasar'))['QTh'];
    QTime: (typeof import('quasar'))['QTime'];
    QTimeline: (typeof import('quasar'))['QTimeline'];
    QTimelineEntry: (typeof import('quasar'))['QTimelineEntry'];
    QToggle: (typeof import('quasar'))['QToggle'];
    QToolbar: (typeof import('quasar'))['QToolbar'];
    QToolbarTitle: (typeof import('quasar'))['QToolbarTitle'];
    QTooltip: (typeof import('quasar'))['QTooltip'];
    QTree: (typeof import('quasar'))['QTree'];
    QUploader: (typeof import('quasar'))['QUploader'];
    QUploaderAddTrigger: (typeof import('quasar'))['QUploaderAddTrigger'];
    QVideo: (typeof import('quasar'))['QVideo'];
    QVirtualScroll: (typeof import('quasar'))['QVirtualScroll'];
  }
}
