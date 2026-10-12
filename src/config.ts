import type {
	ExpressiveCodeConfig,
	LicenseConfig,
	NavBarConfig,
	ProfileConfig,
	SiteConfig,
} from "./types/config";
import { LinkPreset } from "./types/config";

export const siteConfig: SiteConfig = {
	title: "Clairis's Blog",
	subtitle: "欢迎来到 Clairis 的博客",
	lang: "zh_CN",
	themeColor: {
		hue: 250,
		fixed: false,
	},
	banner: {
		enable: true,
		src: "/images/background-fuwari-optimized.webp",
		position: "center",
		credit: {
			enable: false,
			text: "",
			url: "",
		},
	},
	toc: {
		enable: true,
		depth: 2,
	},
	favicon: [{ src: "/favicon.ico", sizes: "32x32" }],
};

export const navBarConfig: NavBarConfig = {
	links: [
		LinkPreset.Home,
		LinkPreset.Archive,
		LinkPreset.About,
		{
			name: "空间",
			url: "/space/",
		},
	],
};

export const profileConfig: ProfileConfig = {
	avatar: "/images/avatar.jpg",
	name: "Clairis",
	bio: "Hi, there ~ 👋",
	links: [
		{
			name: "GitHub",
			icon: "fa6-brands:github",
			url: "https://github.com/LuoHuilin3055",
		},
		{
			name: "NSSCTF",
			icon: "fa6-solid:flag",
			url: "https://www.nssctf.cn/user/47738",
		},
	],
};

export const licenseConfig: LicenseConfig = {
	enable: true,
	name: "CC BY-NC-SA 4.0",
	url: "https://creativecommons.org/licenses/by-nc-sa/4.0/",
};

export const siteFeatureConfig = {
	since: "2026-03-21",
	walineServerURL: "https://clairis-waline.vercel.app",
	featuredPostTitles: [
		"每日一题",
		"GCCCTF的WP",
	],
};

export const expressiveCodeConfig: ExpressiveCodeConfig = {
	theme: "github-dark",
};
